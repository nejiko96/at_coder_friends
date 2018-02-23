# frozen_string_literal: true

require 'uri'
require 'mechanize'
require 'logger'
require 'English'

module AtCoderFriends
  # scrapes AtCoder contest site and
  # - fetches problems
  # - submits sources
  class ScrapingAgent
    include PathUtil

    BASE_URL_FMT = 'http://%<contest>s.contest.atcoder.jp/'
    XPATH_SECTION = '//h3[.="%<title>s"]/following-sibling::section'
    LANG_TBL = {
      'cxx'  => '3003',
      'cs'   => '3006',
      'java' => '3016',
      'rb'   => '3024'
    }.freeze

    attr_reader :contest, :config, :agent

    def initialize(contest, config)
      @contest = contest
      @config = config
      @agent = Mechanize.new
      # @agent.log = Logger.new(STDERR)
    end

    def base_url
      @base_url ||= format(BASE_URL_FMT, contest: contest)
    end

    def sub_url(path)
      URI.join(base_url, path)
    end

    def fetch_all
      puts "***** fetch_all #{@contest} *****"
      login
      fetch_assignments.map do |q, url|
        pbm = fetch_problem(q, url)
        yield pbm if block_given?
        pbm
      end
    end

    def submit(path)
      path, _dir, prg, _base, ext, q = split_prg_path(path)
      puts "***** submit #{prg} *****"
      src = File.read(path, encoding: Encoding::UTF_8)
      login
      post_src(q, ext, src)
    end

    def login
      sleep 0.1
      page = agent.get(sub_url('login'))
      form = page.forms.first
      form.field_with(name: 'name').value = config['user']
      form.field_with(name: 'password').value = config['password']
      sleep 0.1
      form.submit
    end

    def fetch_assignments
      url = sub_url('assignments')
      puts "fetch list from #{url} ..."
      sleep 0.1
      page = agent.get(url)
      ('A'..'Z').each_with_object({}) do |q, h|
        link = page.link_with(text: q)
        link && h[q] = link.href
      end
    end

    def fetch_problem(q, url)
      puts "fetch problem from #{url} ..."
      sleep 0.1
      page = agent.get(url)
      Problem.new(q) do |pbm|
        pbm.html = page.body
        if @contest == 'arc001'
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
      when /^制約$/
        pbm.desc += text
      when /^入出?力$/
        pbm.desc += text
        pbm.fmt = code
      when /^入力例\s*(?<no>[\d０-９]+)$/
        pbm.add_smp($LAST_MATCH_INFO[:no], :in, code)
      when /^出力例\s*(?<no>[\d０-９]+)$/
        pbm.add_smp($LAST_MATCH_INFO[:no], :exp, code)
      end
    end

    def post_src(q, ext, src)
      lang_id = LANG_TBL[ext.downcase]
      raise AppError, ".#{ext} is not available." unless lang_id
      sleep 0.1
      page = agent.get(sub_url('submit'))
      form = page.forms.first
      task_id = form.field_with(name: 'task_id') do |sel|
        option = sel.options.find { |op| op.text.start_with?(q) }
        option&.select || (raise AppError, "unknown problem:#{q}.")
      end
      form.field_with(name: 'language_id_' + task_id.value).value = lang_id
      form.field_with(name: 'source_code').value = src
      sleep 0.1
      form.submit
    end
  end
end
