# frozen_string_literal: true

RSpec.describe AtCoderFriends::RubyGenerator do
  subject(:generator) do
    described_class.new
  end

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) { AtCoderFriends::InputDef.new(type, size, fmt, vars) }
    let(:size) { nil }

    context 'for a plain number' do
      let(:type) { :single }
      let(:fmt) { :number }
      let(:vars) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('A = gets.to_i')
      end
    end

    context 'for plain numbers' do
      let(:type) { :single }
      let(:fmt) { :number }
      let(:vars) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('A, B = gets.split.map(&:to_i)')
      end
    end

    context 'for a plain string' do
      let(:type) { :single }
      let(:fmt) { :string }
      let(:vars) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('A = gets.chomp')
      end
    end

    context 'for plain strings' do
      let(:type) { :single }
      let(:fmt) { :string }
      let(:vars) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('A, B = gets.chomp.split')
      end
    end

    context 'for a horizontal array of numbers' do
      let(:type) { :harray }
      let(:fmt) { :number }
      let(:vars) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('As = gets.split.map(&:to_i)')
      end
    end

    context 'for a horizontal array of strings' do
      let(:type) { :harray }
      let(:fmt) { :string }
      let(:vars) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('As = gets.chomp.split')
      end
    end

    context 'for a horizontal array of characters' do
      let(:type) { :harray }
      let(:fmt) { :char }
      let(:vars) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('As = gets.chomp')
      end
    end

    context 'for single vertical array of numbers' do
      let(:type) { :varray }
      let(:size) { 'N' }
      let(:fmt) { :number }
      let(:vars) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('As = Array.new(N) { gets.to_i }')
      end
    end

    context 'for single vertical array of strings' do
      let(:type) { :varray }
      let(:size) { 'N' }
      let(:fmt) { :string }
      let(:vars) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('As = Array.new(N) { gets.chomp }')
      end
    end

    context 'for multiple vertical array of numbers' do
      let(:type) { :varray }
      let(:size) { 'N' }
      let(:fmt) { :number }
      let(:vars) { %w[A B] }
      it 'generates decl' do
        expect(subject).to match_array(
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
      let(:type) { :varray }
      let(:size) { 'N' }
      let(:fmt) { :string }
      let(:vars) { %w[A B] }
      it 'generates decl' do
        expect(subject).to match_array(
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
      let(:type) { :matrix }
      let(:size) { %w[R C] }
      let(:fmt) { :number }
      let(:vars) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.split.map(&:to_i) }')
      end
    end

    context 'for a matrix of strings' do
      let(:type) { :matrix }
      let(:size) { %w[R C] }
      let(:fmt) { :string }
      let(:vars) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.chomp.split }')
      end
    end

    context 'for a matrix of characters' do
      let(:type) { :matrix }
      let(:size) { %w[R C] }
      let(:fmt) { :char }
      let(:vars) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('Ass = Array.new(R) { gets.chomp }')
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(defs) }
    let(:defs) do
      [
        AtCoderFriends::InputDef.new(:single, nil, :number, %w[N]),
        AtCoderFriends::InputDef.new(:varray, 'N', :number, %w[x y]),
        AtCoderFriends::InputDef.new(:single, nil, :string, %w[Q]),
        AtCoderFriends::InputDef.new(:harray, 'Q', :string, 'a')
      ]
    end

    it 'generates ruby source' do
      expect(subject).to eq(
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
      )
    end
  end
end
