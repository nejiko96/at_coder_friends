# frozen_string_literal: true

module AtCoderFriends
  module TestRunner
    # run test cases for the specified program with sample input/output.
    class Sample < Base
      include PathUtil

      attr_reader :data_dir

      def initialize(ctx)
        super(ctx)
        @data_dir = smp_dir(dir)
      end

      def test_all
        puts "***** test_all #{prg} (#{test_loc}) *****"
        1.upto(999) do |i|
          break unless test(i)
        end
      end

      def test_one(n)
        puts "***** test_one #{prg} (#{test_loc}) *****"
        test(n)
      end

      def test(n)
        id = format('%<q>s_%<n>03d', q: q, n: n)
        files = %w[in out exp].map { |ext| "#{data_dir}/#{id}.#{ext}" }
        run_test(id, *files)
      end
    end
  end
end