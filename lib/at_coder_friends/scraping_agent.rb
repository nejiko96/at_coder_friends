# frozen_string_literal: true

require 'mechanize'
require 'logger'

module AtCoderFriends
  BASE_URL_FMT = 'http://%s.contest.atcoder.jp/'
  LANG_TBL = {
    'cxx' => '3003',
    'cs'  => '3006',
    'rb'  => '3024'
  }.freeze

  class ScrapingAgent
    def initialize(contest, config)
      @config = config
      @agent = Mechanize.new
      # @agent.log = Logger.new(STDERR)
      @base_url = format(BASE_URL_FMT, contest.delete('#').downcase)
    end

    def login
      sleep 0.1
      page = @agent.get(@base_url + 'login')
      form = page.forms[0]
      form.field_with(name: 'name').value = @config['user']
      form.field_with(name: 'password').value = @config['password']
      sleep 0.1
      form.submit
    end

    def submit_src(q, lang_id, src)
      sleep 0.1
      page = @agent.get(@url + 'submit')
      form = page.forms[0]
      selectlist = form.field_with(name: 'task_id')
      task_id = selectlist.options.find { |opt| opt.text.start_with?(q) }.value
      selectlist.value = task_id
      form.field_with(name: "language_id_#{task_id}").value = lang_id
      form.field_with(name: 'source_code').value = src
      sleep 0.1
      form.submit
    end

    def fetch_assignments
      url = @url + 'assignments'
      puts "fetch from #{url} ..."
      sleep 0.1
      ret = {}
      page = @agent.get(url)
      ('A'..'Z').each do |q|
        link = page.link_with(text: q)
        next unless link
        ret[q] = link.href
      end
      ret
    end

    def fetch_problem(q, url)
      puts "fetch from #{url} ..."
      sleep 0.1
      page = @agent.get(url)
      pbm = Problem.new(q)
      #=== ARC#001 special =========
      # page.search('//h3').each do |h3|
      #   title = h3.content.strip
      #   section = page.search('//h3[.="' + h3.content + '"]/following-sibling::section')
      #   next if section.empty?
      #   section = section[0]
      #=============================
      page.search('//*[./h3]').each do |section|
        h3 = section.search('h3')
        title = h3[0].content.strip
        pre = section.search('pre')
        pre_body = pre[0].content.lstrip.gsub("\r\n", "\n") unless pre.empty?
        case title
        when /^制約$/
          pbm.desc += section.content
        when /^入力$/, /^入出力$/
          pbm.desc += section.content
          pbm.fmt = pre_body
        when /^入力例\s*(?<no>[\d０-９]+)$/
          pbm.add_smp(no, :in, pre_body)
        when /^出力例\s*(?<no>[\d０-９]+)$/
          pbm.add_smp(no, :exp, pre_body)
        end
      end
      pbm
    end

    def submit(path)
      prog = File.basename(path)
      base, ext = prog.split('.')
      q = base.split('_')[0]
      src = IO.read(path, encoding: Encoding::UTF_8)
      lang_id = LANG_TBL[ext.downcase]
      unless lang_id
        puts ".#{ext} is not supported."
        return
      end
      puts "***** submit #{prog} *****"
      login
      submit_src(q, lang_id, src)
    end

    def fetch_all
      login
      assignments = fetch_assignments
      ret = {}
      assignments.each do |q, url|
        ret[q] = pbm = fetch_problem(q, url)
        yield pbm if block_given?
      end
      ret
    end
  end
end
