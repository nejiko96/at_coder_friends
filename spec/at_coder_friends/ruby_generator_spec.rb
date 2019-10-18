# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::RubyBuiltin do
  subject(:generator) { described_class.new }

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
  end

  describe '#generate' do
    subject { generator.generate(url, defs) }
    let(:url) { 'https://atcoder.jp/contests/practice/tasks/practice_1' }
    let(:defs) do
      [
        AtCoderFriends::Problem::InputFormat.new(:single, :number, %w[N]),
        AtCoderFriends::Problem::InputFormat.new(
          :varray, :number, %w[x y], %w[N]
        ),
        AtCoderFriends::Problem::InputFormat.new(:single, :string, %w[Q]),
        AtCoderFriends::Problem::InputFormat.new(:harray, :string, %w[a], %w[Q])
      ]
    end

    it 'generates ruby source' do
      expect(subject).to eq(
        <<~SRC
          # https://atcoder.jp/contests/practice/tasks/practice_1

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
end
