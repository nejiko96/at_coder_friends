# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::AnyBuiltin do
  subject(:generator) { described_class.new }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:md)
    end
  end

  describe '#gen_const' do
    subject { constants.map { |c| generator.gen_const(c) } }
    let(:constants) do
      [
        AtCoderFriends::Problem::Constant.new('C_i', :max, '2*10^5'),
        AtCoderFriends::Problem::Constant.new(nil, :mod, '998,244,353')
      ]
    end

    it 'generates constant decls' do
      expect(subject).to match(
        [
          'type=max name=C_i value=2*10^5',
          'type=mod name= value=998,244,353'
        ]
      )
    end
  end

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(
        container: container,
        item: item,
        names: names,
        size: size,
        delim: delim
      )
    end
    let(:names) { %w[A] }
    let(:size) { [] }
    let(:delim) { '' }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      it 'generates decl' do
        expect(subject).to eq('single number([]) ["A"] [] ')
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(pbm) }
    let(:pbm) do
      AtCoderFriends::Problem.new('A') do |pbm|
        pbm.formats_src = formats
        pbm.constants = constants
      end
    end

    before do
      allow(pbm).to receive(:url) do
        'https://atcoder.jp/contests/practice/tasks/practice_1'
      end
    end
    let(:formats) do
      [
        AtCoderFriends::Problem::InputFormat.new(
          container: :single, names: %w[N]
        ),
        AtCoderFriends::Problem::InputFormat.new(
          container: :varray, names: %w[x y], size: %w[N]
        ),
        AtCoderFriends::Problem::InputFormat.new(
          container: :single, item: :string, names: %w[Q]
        ),
        AtCoderFriends::Problem::InputFormat.new(
          container: :harray, item: :string, names: %w[a], size: %w[Q]
        )
      ]
    end
    let(:constants) do
      [
        AtCoderFriends::Problem::Constant.new('N', :max, '100000'),
        AtCoderFriends::Problem::Constant.new(nil, :mod, '10^9+7')
      ]
    end

    it 'generates source' do
      expect(subject).to start_with(
        <<~SRC
          AnyBuiltin Generator
          ====================
        SRC
      )
    end

    it 'generates problem URL' do
      expect(subject).to include(
        <<~SRC
          ## Problem URL
          https://atcoder.jp/contests/practice/tasks/practice_1
        SRC
      )
    end

    it 'generates constant list' do
      expect(subject).to include(
        <<~SRC
          ## Constants
          - [type=max name=N value=100000]
          - [type=mod name= value=10^9+7]
        SRC
      )
    end

    it 'generates variable list' do
      expect(subject).to include(
        <<~SRC
          ## Variables
          - [single number([]) ["N"] [] ]
          - [varray number([]) ["x", "y"] ["N"] ]
          - [single string([]) ["Q"] [] ]
          - [harray string([]) ["a"] ["Q"] ]
        SRC
      )
    end
  end
end
