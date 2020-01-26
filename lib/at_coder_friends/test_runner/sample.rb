# frozen_string_literal: true

module AtCoderFriends
  module TestRunner
    # run test cases for the specified program with sample input/output.
    class Sample < Base
      attr_reader :data_dir

      def initialize(ctx)
        super(ctx)
        @data_dir = ctx.path_info.smp_dir
      end

      def test_all
        puts "***** test_all #{prg} (#{test_loc}) *****"
        results = Dir["#{data_dir}/#{q}_*.in"].sort.map do |infile|
          id = File.basename(infile, '.in').sub(/[^_]+_/, '')
          test(id)
        end
        !results.empty? && results.all?
      end

      def test_one(id)
        puts "***** test_one #{prg} (#{test_loc}) *****"
        test(id)
      end

      def test(id)
        id = format('%<q>s_%<id>s', q: q, id: id)
        files = %w[in out exp].map { |ext| "#{data_dir}/#{id}.#{ext}" }
        run_test(id, *files)
      end
    end
  end
end
