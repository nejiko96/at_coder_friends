# frozen_string_literal: true

module AtCoderFriends
  module TestRunner
    # run test cases for the specified program with judge input/output.
    class Judge < Base
      attr_reader :data_dir, :result_dir

      def initialize(ctx)
        super(ctx)
        @data_dir = ctx.path_info.cases_dir
        @result_dir = ctx.path_info.cases_out_dir
      end

      def judge_all
        puts "***** judge_all #{prg} (#{test_loc}) *****"
        results = Dir["#{data_dir}/#{q}/in/*"].sort.map do |infile|
          id = File.basename(infile)
          judge(id, detail: false)
        end
        !results.empty? && results.all?
      end

      def judge_one(id)
        puts "***** judge_one #{prg} (#{test_loc}) *****"
        judge(id, detail: true)
      end

      def judge(id, detail: true)
        @detail = detail
        infile = "#{data_dir}/#{q}/in/#{id}"
        outfile = "#{result_dir}/#{q}/result/#{id}"
        expfile = "#{data_dir}/#{q}/out/#{id}"
        run_test(id, infile, outfile, expfile)
      end
    end
  end
end
