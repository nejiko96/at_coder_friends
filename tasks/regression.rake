# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'mechanize'
require 'at_coder_friends'

module AtCoderFriends
  # tasks for regression test
  module Regression
    module_function

    CONTEST_LIST_URL = 'https://kenkoooo.com/atcoder/resources/contests.json'
    ACF_HOME = File.realpath(File.join(__dir__, '..'))
    REGRESSION_HOME = File.join(ACF_HOME, 'regression')
    PAGES_DIR = File.join(REGRESSION_HOME, 'pages')
    EMIT_ORG_DIR = File.join(REGRESSION_HOME, 'emit_org')
    EMIT_DIR_FMT = File.join(REGRESSION_HOME, 'emit_%<now>s')

    def setup
      rmdir_force(PAGES_DIR)
      rmdir_force(EMIT_ORG_DIR)
      contest_id_list.each do |contest|
        begin
          ctx = context(EMIT_ORG_DIR, contest)
          ctx.scraping_agent.fetch_all do |pbm|
            begin
              html_path = File.join(PAGES_DIR, contest, "#{pbm.q}.html")
              save_file(html_path, pbm.page.body)
              pipeline(ctx, pbm)
            rescue StandardError => e
              p e
            end
          end
        rescue StandardError => e
          p e
        end
        sleep 3
      end
    end

    def check_diff
      emit_dir = format(EMIT_DIR_FMT, now: Time.now.strftime('%Y%m%d%H%M%S'))
      rmdir_force(emit_dir)

      local_pbm_list.each do |contest, q, url|
        ctx = context(emit_dir, contest)
        pbm = ctx.scraping_agent.fetch_problem(q, url)
        pipeline(ctx, pbm)
      end

      system("diff -r #{EMIT_ORG_DIR} #{emit_dir}")
    end

    def section_list
      agent = Mechanize.new
      list = local_pbm_list.flat_map do |contest, q, url|
        page = agent.get(url)
        %w[h2 h3].flat_map do |tag|
          page.search(tag).map do |h|
            { contest: contest, q: q, text: normalize(h.content) }
          end
        end
      end
      list.group_by { |sec| sec[:text] }.each do |k, vs|
        puts [k, vs.size, vs[0][:contest], vs[0][:q]].join("\t")
      end
    end

    def check_parse
      agent = Mechanize.new
      list = local_pbm_list.map do |contest, q, url|
        page = agent.get(url)
        page.search('br').each { |br| br.replace("\n") }
        pbm = Problem.new(q) { |o| o.page = page }
        Parser::Main.process(pbm)
        no_fmt = pbm.fmt.empty?
        no_smp = pbm.smps.all? { |smp| smp.txt.empty? }
        [contest, q, [no_fmt, no_smp]]
      end
      report(list)
    end

    INOUT_TITLES = %w[入出力 入出力形式 inputoutput inputandoutput].freeze

    SAMPLE_TITLES = %w[
      入出力例 入出力例{n} 入出力の例 サンプル
      sampleinputoutput sampleinputoutput{n} sampleinputandoutput
      sample samples
    ].freeze

    def check_interactive
      agent = Mechanize.new
      list = local_pbm_list.map do |contest, q, url|
        page = agent.get(url)
        body = page.body.force_encoding('utf-8')
        f_int = body.match(/(インタラクティブ|interactive|リアクティブ|reactive)/i)
        f_flush = body.match(/flush/i)
        f_inout = false
        f_sample = false

        %w[h2 h3].each do |tag|
          page.search(tag).each do |h|
            text = normalize(h.content)
            f_inout = true if INOUT_TITLES.include?(text)
            next unless SAMPLE_TITLES.include?(text)

            nx = h.next
            while nx && nx.name != h.name
              if nx.name == 'table' || nx.search('table')[0]
                f_sample = true
                break
              end
              nx = nx.next
            end
          end
        end
        [contest, q, [f_int, f_flush, f_inout, f_sample]]
      end
      report(list)
    end

    OUTPUT_TITLES = %w[
      出力 出力形式
      output outputs outputformat
    ].freeze

    def check_2value
      agent = Mechanize.new
      local_pbm_list.map do |contest, q, url|
        page = agent.get(url)
        page.search('br').each { |br| br.replace("\n") }
        output = ''
        %w[h2 h3].each do |tag|
          page.search(tag).each do |h|
            text = normalize(h.content)
            if OUTPUT_TITLES.include?(text)
              nx = h.next
              while nx && nx.name != h.name
                output += nx.content.gsub("\r\n", "\n")
                nx = nx.next
              end
            end
          end
        end
        pbm = Problem.new(q) { |o| o.page = page }
        Parser::Main.process(pbm)
        vs = pbm.smps.select { |smp| smp.ext == :exp }.map(&:txt)
        us = vs.uniq.map(&:chomp)
        xs = us.map { |u| Regexp.escape(u) }
        [contest, q, us, xs, output]
      end
      .select do |_, _, us, xs, output|
        next false unless us.size == 2
        next false unless us.all? { |u| u.count("\n").zero? }
        next false if us.any? { |u| u.match(/^[0-9\s]*$/) }
        next false unless output.match(/(#{xs[0]}.+#{xs[1]}|#{xs[1]}.+#{xs[0]})/)
        true
      end
      .each do |contest, q, us, xs, output|
        us.reverse! if output.match(/#{xs[1]}.+#{xs[0]}/)
        puts [contest, q, *us].join("\t")
      end
    end

    def contest_id_list
      uri = URI.parse(CONTEST_LIST_URL)
      json = Net::HTTP.get(uri)
      contests = JSON.parse(json)
      puts "Total #{contests.size} contests"
      contests.map { |h| h['id'] }
    end

    def local_pbm_list
      Dir.glob(PAGES_DIR + '/**/*.html').map do |pbm_path|
        contest = File.basename(File.dirname(pbm_path))
        q = File.basename(pbm_path, '.html')
        url = "file://#{pbm_path}"
        [contest, q, url]
      end
    end

    def pbm_list_from_file(file)
      dat = File.join(REGRESSION_HOME, file)
      CSV.read(dat, col_sep: "\t", headers: false).map do |contest, q|
        pbm_path = File.join(PAGES_DIR, contest, "#{q}.html")
        url = "file://#{pbm_path}"
        [contest, q, url]
      end
    end

    def context(root, contest)
      Context.new({}, File.join(root, contest))
    end

    def rmdir_force(dir)
      FileUtils.rm_r(dir) if Dir.exist?(dir)
    end

    def save_file(path, content)
      dir = File.dirname(path)
      FileUtils.makedirs(dir) unless Dir.exist?(dir)
      File.binwrite(path, content)
    end

    def pipeline(ctx, pbm)
      @rb_gen ||= RubyGenerator.new
      @cxx_gen ||= CxxGenerator.new
      Parser::Main.process(pbm)
      @rb_gen.process(pbm)
      @cxx_gen.process(pbm)
      ctx.emitter.emit(pbm)
    end

    def normalize(s)
      s
        .tr('　０-９Ａ-Ｚａ-ｚ', ' 0-9A-Za-z')
        .gsub(/[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 ]/, '')
        .gsub(/\d+/, '{N}')
        .gsub(' ', '')
        .downcase
        .strip
    end

    def report(list)
      list
        .select { |_, _, flags| flags.any? }
        .map { |c, q, flags| [c, q, flags.map { |f| f ? '◯' : '-' }] }
        .sort
        .each { |args| puts args.flatten.join("\t") }
    end
  end
end

namespace :regression do
  desc 'setup regression environment'
  task :setup do
    AtCoderFriends::Regression.setup
  end

  desc 'run regression check'
  task :check_diff do
    AtCoderFriends::Regression.check_diff
  end

  desc 'list all section titles'
  task :section_list do
    AtCoderFriends::Regression.section_list
  end

  desc 'checks page parse result'
  task :check_parse do
    AtCoderFriends::Regression.check_parse
  end

  desc 'checks interactive flags'
  task :check_interactive do
    AtCoderFriends::Regression.check_interactive
  end

  desc 'checks 2-value problems'
  task :check_2value do
    AtCoderFriends::Regression.check_2value
  end
end
