# frozen_string_literal: true

module AtCoderFriends
  # run test cases for the specified program with sample input/output.
  class SampleTestRunner < TestRunner
    include PathUtil

    def initialize(ctx)
      super(ctx)
      @smp_dir = smp_dir(@dir)
    end

    def test_all
      puts "***** test_all #{@prg} *****"
      1.upto(999) do |i|
        break unless test(i)
      end
    end

    def test_one(n)
      puts "***** test_one #{@prg} *****"
      test(n)
    end

    def test(n)
      id = format('%<q>s_%<n>03d', q: @q, n: n)
      files = %w[in out exp].map { |ext| "#{@smp_dir}/#{id}.#{ext}" }
      run_test(id, *files)
    end
  end
end
