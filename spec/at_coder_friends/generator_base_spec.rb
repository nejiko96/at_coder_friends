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

  describe '#config_file_ext' do
    subject { generator.config_file_ext }

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
        expect(subject).to eq(:cpp)
      end
    end
  end

  describe '#config_template' do
    subject { generator.config_template }

    context 'with default configuration' do
      it 'returns template file name' do
        expect(subject).to eq(generator.attrs.template)
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        { 'template' => 'custom_default.cxx' }
      end

      it 'returns template file name' do
        expect(subject).to eq('custom_default.cxx')
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

    context 'when the path starts with "@"' do
      let(:cfg) do
        { 'template' => '@/sample_default.cxx' }
      end

      it 'replaces "@" to the template folder in the gem' do
        expect(subject).to end_with('/at_coder_friends/templates/sample_default.cxx')
      end
    end

    context 'when the path not starts with "@"' do
      let(:cfg) do
        { 'template' => '/@sample_default.cxx' }
      end

      it 'not replace "@"' do
        expect(subject).to eq('/@sample_default.cxx')
      end
    end
  end

  describe '#config_fragments' do
    subject { generator.config_fragments }

    context 'with default configuration' do
      it 'returns fragments file name' do
        expect(subject).to eq(generator.attrs.fragments)
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        { 'fragments' => 'custom_fragments.yml' }
      end

      it 'returns fragments file name' do
        expect(subject).to eq('custom_fragments.yml')
      end
    end

    context 'when the path starts with "@"' do
      let(:cfg) do
        { 'fragments' => '@/sample_fragments.yml' }
      end

      it 'replaces "@" to the template folder in the gem' do
        expect(subject).to end_with('/at_coder_friends/templates/sample_fragments.yml')
      end
    end

    context 'when the path not starts with "@"' do
      let(:cfg) do
        { 'fragments' => '/@sample_fragments.yml' }
      end

      it 'not replace "@"' do
        expect(subject).to eq('/@sample_fragments.yml')
      end
    end
  end
end
