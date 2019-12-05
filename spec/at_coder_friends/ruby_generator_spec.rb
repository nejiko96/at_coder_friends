# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::RubyBuiltin do
  subject(:generator) { described_class.new(cfg) }
  let(:cfg) { nil }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:rb)
    end
  end

  describe '#gen_consts' do
    subject { generator.gen_consts(constants) }
    let(:constants) do
      [
        AtCoderFriends::Problem::Constant.new('N', :max, '10,000'),
        AtCoderFriends::Problem::Constant.new(nil, :mod, '998,244,353')
      ]
    end

    it 'generates constant decls' do
      expect(subject).to match(
        [
          'MOD = 998_244_353'
        ]
      )
    end
  end

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(container, item, names, size)
    end
    let(:names) { %w[A] }
    let(:size) { [] }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      it 'generates decl' do
        expect(subject).to eq('A = gets.to_i')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('A, B = gets.split.map(&:to_i)')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      it 'generates decl' do
        expect(subject).to eq('A = gets.chomp')
      end
    end

    context 'for plain strings' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('A, B = gets.chomp.split')
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:item) { :number }
      it 'generates decl' do
        expect(subject).to eq('As = gets.split.map(&:to_i)')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:item) { :string }
      it 'generates decl' do
        expect(subject).to eq('As = gets.chomp.split')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      it 'generates decl' do
        expect(subject).to eq('As = gets.chomp')
      end
    end

    context 'for single vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('As = Array.new(N) { gets.to_i }')
      end
    end

    context 'for single vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('As = Array.new(N) { gets.chomp }')
      end
    end

    context 'for multiple vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'As = Array.new(N)',
            'Bs = Array.new(N)',
            'N.times do |i|',
            '  As[i], Bs[i] = gets.split.map(&:to_i)',
            'end'
          ]
        )
      end
    end

    context 'for multple vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'As = Array.new(N)',
            'Bs = Array.new(N)',
            'N.times do |i|',
            '  As[i], Bs[i] = gets.chomp.split',
            'end'
          ]
        )
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:item) { :number }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.split.map(&:to_i) }')
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:item) { :string }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.chomp.split }')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:item) { :char }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.chomp }')
      end
    end

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:item) { :number }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'Ks = Array.new(N)',
            'Ass = Array.new(N)',
            'N.times do |i|',
            '  Ks[i], *Ass[i] = gets.split.map(&:to_i)',
            'end'
          ]
        )
      end
    end

    context 'for a vertical array and a matrix characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'Ks = Array.new(Q)',
            'pss = Array.new(Q)',
            'Q.times do |i|',
            '  Ks[i], pss[i] = gets.chomp.split',
            'end'
          ]
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:item) { :number }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'cityss = Array.new(M)',
            'costs = Array.new(M)',
            'M.times do |i|',
            '  *cityss[i], costs[i] = gets.split.map(&:to_i)',
            'end'
          ]
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:item) { :number }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'idolss = Array.new(1) { Array.new(C_1) }',
            'pss = Array.new(1) { Array.new(C_1) }',
            '1.times do |i|',
            '  C_1.times do |j|',
            '    idolss[i][j], pss[i][j] = gets.split.map(&:to_i)',
            '  end',
            'end'
          ]
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:item) { :number }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'xss = Array.new(Q)',
            'yss = Array.new(Q)',
            'Q.times do |i|',
            '  xss[i], yss[i] = ' \
            'gets.split.map(&:to_i).each_slice(2).to_a.transpose',
            'end'
          ]
        )
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(pbm) }
    let(:pbm) do
      AtCoderFriends::Problem.new('A') do |pbm|
        pbm.formats_src = formats
        pbm.constants = constants
        pbm.options.interactive = interactive
        pbm.options.binary_values = binary_values
      end
    end

    context 'for a general problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_1'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            :single, :number, %w[N], []
          ),
          AtCoderFriends::Problem::InputFormat.new(
            :varray, :number, %w[x y], %w[N]
          ),
          AtCoderFriends::Problem::InputFormat.new(
            :single, :string, %w[Q], []
          ),
          AtCoderFriends::Problem::InputFormat.new(
            :harray, :string, %w[a], %w[Q]
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '100000'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '10^9+7')
        ]
      end
      let(:interactive) { false }
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~SRC
            # https://atcoder.jp/contests/practice/tasks/practice_1

            MOD = 10**9+7

            N = gets.to_i
            xs = Array.new(N)
            ys = Array.new(N)
            N.times do |i|
              xs[i], ys[i] = gets.split.map(&:to_i)
            end
            Q = gets.chomp
            as = gets.chomp.split

            puts ans
          SRC
        )
      end
    end

    context 'for an interactive problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_2'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            :single, :number, %w[N Q], []
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '26'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '2^32')
        ]
      end
      let(:interactive) { true }
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~'SRC'
            # https://atcoder.jp/contests/practice/tasks/practice_2

            def query(*args)
              puts "? #{args.join(' ')}"
              STDOUT.flush
              if $DEBUG
                res = 'generate response from @source'
                res.tap { |res| @responses << res }
              else
                gets.chomp
              end
            end

            $DEBUG = true

            MOD = 2**32

            N, Q = gets.split.map(&:to_i)

            if $DEBUG
              @responses = []
              @source = gets.chomp
            end

            puts "! #{ans}"
            STDOUT.flush

            if $DEBUG
              puts "----------------------------------------"
              puts "query count: #{@responses.size}"
              puts "query results:"
              @responses.each { |res| puts res }
              puts "----------------------------------------"
            end
          SRC
        )
      end
    end

    context 'for a binary problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/abc006/tasks/abc006_1'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            :single, :number, %w[N], []
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '9')
        ]
      end
      let(:interactive) { false }
      let(:binary_values) { %w[YES NO] }

      it 'generates source' do
        expect(subject).to eq(
          <<~'SRC'
            # https://atcoder.jp/contests/abc006/tasks/abc006_1


            N = gets.to_i

            puts cond ? 'YES' : 'NO'
          SRC
        )
      end
    end
  end
end
