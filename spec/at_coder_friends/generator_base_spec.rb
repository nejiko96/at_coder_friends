# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::CxxBuiltin do
  subject(:generator) { described_class.new(cfg) }
  let(:cfg) { nil }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(generator.attrs.file_ext)
    end
  end

  describe '#select_template' do
    subject { generator.select_template }

    context 'with default configuration' do
      it 'returns template file name' do
        expect(subject).to eq(generator.attrs.default_template)
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        { 'default_template' => 'customized_default.cxx' }
      end

      it 'returns template file name' do
        expect(subject).to eq('customized_default.cxx')
      end
    end
  end
end
