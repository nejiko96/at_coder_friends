# frozen_string_literal: true

require 'uri'
require 'cgi'
require 'json'
require 'mechanize'
require 'logger'
require 'English'
require 'io/console'

module AtCoderFriends
  # scrapes AtCoder contest site and
  # - fetches problems
  # - submits sources
  # - runs tests on custom_test page
  class ScrapingAgent
    include PathUtil
    BASE_URL      = 'https://atcoder.jp/'
    XPATH_SECTION = '//h3[.="%<title>s"]/following-sibling::section'
    SESSION_STORE =
      File.join(Dir.home, '.at_coder_friends', '%<user>s_session.yml')

    attr_reader :ctx, :agent

    def initialize(ctx)
      @ctx = ctx
      @agent = Mechanize.new
      agent.pre_connect_hooks << proc { sleep 0.1 }
      agent.log = Logger.new(STDERR) if ctx.options[:debug]
      agent.cookie_jar.load(session_store) if File.exist?(session_store)
    end

    def save_session
      dir = File.dirname(session_store)
      Dir.mkdir(dir) unless Dir.exist?(dir)
      agent.cookie_jar.save_as(session_store)
    end

    def contest
      @contest ||= contest_name(ctx.path)
    end

    def config
      ctx.config
    end

    def common_url(path)
      File.join(BASE_URL, path)
    end

    def contest_url(path = '')
      File.join(BASE_URL, 'contests', contest, path)
    end

    def session_store
      @session_store ||= format(SESSION_STORE, user: config['user'])
    end

    def constraints_pat
      config['constraints_pat'] || '^制約$'
    end

    def input_fmt_pat
      config['input_fmt_pat'] || '^入出?力$'
    end

    def input_smp_pat
      config['input_smp_pat'] || '^入力例\s*(?<no>[\d０-９]+)$'
    end

    def output_smp_pat
      config['output_smp_pat'] || '^出力例\s*(?<no>[\d０-９]+)$'
    end

    def fetch_all
      puts "***** fetch_all #{contest} *****"
      fetch_assignments.map do |q, url|
        pbm = fetch_problem(q, url)
        yield pbm if block_given?
        pbm
      end
    end

    def submit
      path, _dir, prg, _base, ext, q = split_prg_path(ctx.path)
      puts "***** submit #{prg} *****"
      src = File.read(path, encoding: Encoding::UTF_8)
      post_src(q, ext, src)
    end

    def code_test(infile)
      path, _dir, _prg, _base, ext, _q = split_prg_path(ctx.path)
      src = File.read(path, encoding: Encoding::UTF_8)
      data = File.read(infile)
      code_test_loop(ext, src, data)
    end

    def fetch_with_auth(url)
      begin
        page = agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        raise e unless e.response_code == '404'

        page = agent.get(common_url('login') + '?continue=' + CGI.escape(url))
      end

      if page.uri.path == '/login'
        user, pass = read_auth
        form = page.forms[1]
        form.field_with(name: 'username').value = user
        form.field_with(name: 'password').value = pass
        page = form.submit
      end

      page.uri.path == '/login' && (raise AppError, 'Authentication failed.')
      page
    end

    def read_auth
      user = config['user'].to_s
      if user.empty?
        print('Enter username:')
        user = STDIN.gets.chomp
      end
      pass = config['password'].to_s
      if pass.empty?
        print("Enter password for #{user}:")
        pass = STDIN.noecho(&:gets).chomp
        puts
      end
      [user, pass]
    end

    def fetch_assignments
      url = contest_url('tasks')
      puts "fetch list from #{url} ..."
      page = fetch_with_auth(url)
      page
        .search('//table[1]//td[1]//a')
        .each_with_object({}) do |a, h|
          h[a.text] = a[:href]
        end
    end

    def fetch_problem(q, url)
      puts "fetch problem from #{url} ..."
      page = fetch_with_auth(url)
      Problem.new(q) do |pbm|
        pbm.html = page.body
        if contest == 'arc001'
          page.search('//h3').each do |h3|
            query = format(XPATH_SECTION, title: h3.content)
            sections = page.search(query)
            sections[0] && parse_section(pbm, h3, sections[0])
          end
        else
          page.search('//*[./h3]').each do |section|
            h3 = section.search('h3')[0]
            parse_section(pbm, h3, section)
          end
        end
      end
    end

    def parse_section(pbm, h3, section)
      title = h3.content.strip
      title.delete!("\u008f\u0090") # agc002
      text = section.content
      code = section.search('pre')[0]&.content || ''
      case title
      when /#{constraints_pat}/
        pbm.desc += text
      when /#{input_fmt_pat}/
        pbm.desc += text
        pbm.fmt = code
      when /#{input_smp_pat}/
        pbm.add_smp($LAST_MATCH_INFO[:no], :in, code)
      when /#{output_smp_pat}/
        pbm.add_smp($LAST_MATCH_INFO[:no], :exp, code)
      end
    end

    def post_src(q, ext, src)
      page = fetch_with_auth(contest_url('submit'))
      form = page.forms[1]
      form.field_with(name: 'data.TaskScreenName') do |sel|
        option = sel.options.find { |op| op.text.start_with?(q) }
        option&.select || (raise AppError, "unknown problem:#{q}.")
      end
      form.add_field!('data.LanguageId', lang_id(ext))
      form.field_with(name: 'sourceCode').value = src
      form.submit
    end

    def code_test_loop(ext, src, data)
      page = fetch_with_auth(contest_url('custom_test'))
      script = page.search('script').text
      csrf_token = script.scan(/var csrfToken = "(.*)"/)[0][0]
      payload = {
        'data.LanguageId' => lang_id(ext),
        'sourceCode' => src,
        'input' => data,
        'csrf_token' => csrf_token
      }

      page = agent.post(contest_url('custom_test/submit/json'), payload)
      msg = page.body
      raise AppError, msg unless msg.empty?

      100.times do
        page = agent.get(contest_url('custom_test/json?reload=true'))
        data = JSON.parse(page.body)
        return nil unless data.is_a?(Hash) && data['Result']
        return data if data.dig('Result', 'Status') == 3
        return data unless data['Interval']

        sleep 1.0 * data['Interval'] / 1000
      end

      nil
    end

    def lang_list
      @lang_list ||= begin
        page = fetch_with_auth(contest_url('custom_test'))
        form = page.forms[1]
        sel = form.field_with(name: 'data.LanguageId')
        sel && sel
          .options
          .reject { |opt| opt.value.empty? }
          .map do |opt|
            { v: opt.value, t: opt.text }
          end
      end
    end

    def lang_list_txt
      lang_list
        &.map { |opt| "#{opt[:v]} - #{opt[:t]}" }
        &.join("\n")
    end

    def lang_id(ext)
      config.dig('ext_settings', ext, 'submit_lang') || (
        msg = <<~MSG
          submit_lang for .#{ext} is not specified.
          Available languages:
          #{lang_list_txt || '(failed to fetch)'}
        MSG
        raise AppError, msg
      )
    end
  end
end
