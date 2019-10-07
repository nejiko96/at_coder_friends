# frozen_string_literal: true

module AtCoderFriends
  module TestRunner
    # run test cases for the specified program with judge input/output.
    class Judge < Base
      include PathUtil

      attr_reader :data_dir, :result_dir

      def initialize(ctx)
        super(ctx)
        @data_dir = cases_dir(dir)
        @result_dir = cases_dir(tmp_dir(path))
      end

      def judge_all
        puts "***** judge_all #{prg} (#{test_loc}) *****"
        Dir["#{data_dir}/#{q}/in/*.txt"].sort.each do |infile|
          id = File.basename(infile, '.txt')
          judge(id, false)
        end
      end

      def judge_one(id)
        puts "***** judge_one #{prg} (#{test_loc}) *****"
        judge(id, true)
      end

      def judge(id, detail = true)
        @detail = detail
        infile = "#{data_dir}/#{q}/in/#{id}.txt"
        outfile = "#{result_dir}/#{q}/result/#{id}.txt"
        expfile = "#{data_dir}/#{q}/out/#{id}.txt"
        run_test(id, infile, outfile, expfile)
      end

      def show_result(is_success, input, result, expected)
        print detail_str(input, result, expected) if @detail
        puts result_str(is_success, result, expected)
      end
    end
  end
end
