# frozen_string_literal: true

RSpec.describe AtCoderFriends::RubyGenerator do
  subject(:generator) { described_class.new }

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) { AtCoderFriends::InputDef.new(container, item, names, size) }
    let(:size) { nil }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A] }
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
      let(:names) { %w[A] }
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
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('As = gets.split.map(&:to_i)')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:item) { :string }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('As = gets.chomp.split')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('As = gets.chomp')
      end
    end

    context 'for single vertical array of numbers' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :number }
      let(:names) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('As = Array.new(N) { gets.to_i }')
      end
    end

    context 'for single vertical array of strings' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :string }
      let(:names) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('As = Array.new(N) { gets.chomp }')
      end
    end

    context 'for multiple vertical array of numbers' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :number }
      let(:names) { %w[A B] }
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
      let(:size) { 'N' }
      let(:item) { :string }
      let(:names) { %w[A B] }
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
      let(:size) { %w[R C] }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.split.map(&:to_i) }')
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :string }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.chomp.split }')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :char }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.chomp }')
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(defs) }
    let(:defs) do
      [
        AtCoderFriends::InputDef.new(:single, :number, %w[N]),
        AtCoderFriends::InputDef.new(:varray, :number, %w[x y], 'N'),
        AtCoderFriends::InputDef.new(:single, :string, %w[Q]),
        AtCoderFriends::InputDef.new(:harray, :string, 'a', 'Q')
      ]
    end

    it 'generates ruby source' do
      expect(subject).to eq(
        # rubocop:disable Layout/EmptyLinesAroundArguments
        <<~SRC
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
        # rubocop:enable Layout/EmptyLinesAroundArguments
      )
    end
  end
end
