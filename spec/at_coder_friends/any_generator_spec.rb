# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::AnyBuiltin do
  subject(:generator) { described_class.new }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:txt)
    end
  end

  describe '#generate' do
    subject { generator.generate(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }

    it 'generates source' do
      expect(subject).to start_with(
        <<~SRC
          AnyBuiltin Generator
          ====================
        SRC
      )
    end
  end
end
