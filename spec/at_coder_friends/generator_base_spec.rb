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

  describe '#select_file_ext' do
    subject { generator.select_file_ext }

    context 'with default configuration' do
      it 'returns file extension' do
        expect(subject).to eq(generator.attrs.file_ext)
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        { 'file_ext' => 'cpp' }
      end

      it 'returns file extension' do
        expect(subject).to eq('cpp')
      end
    end
  end

  describe '#select_template' do
    subject { generator.select_template }

    context 'with default configuration' do
      it 'returns template file name' do
        expect(subject).to eq(generator.attrs.template)
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        { 'template' => 'customized_default.cxx' }
      end

      it 'returns template file name' do
        expect(subject).to eq('customized_default.cxx')
      end
    end

    context 'with old configuration' do
      let(:cfg) do
        { 'default_template' => 'old_default.cxx' }
      end

      it 'returns template file name' do
        expect(subject).to eq('old_default.cxx')
      end
    end
  end

  describe '#select_fragments' do
    subject { generator.select_fragments }

    context 'with default configuration' do
      it 'returns fragments file name' do
        expect(subject).to eq(generator.attrs.fragments)
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        { 'fragments' => 'customized_fragments.yaml' }
      end

      it 'returns fragments file name' do
        expect(subject).to eq('customized_fragments.yaml')
      end
    end
  end
end
