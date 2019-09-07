# frozen_string_literal: true

RSpec.describe AtCoderFriends::ConfigLoader do
  include_context :atcoder_env

  subject(:loader) { described_class }

  describe '#load_config' do
    subject { loader.load_config(target_dir) }

    context 'when the file exists in target directory' do
      let(:target_dir) { project_root }
      it 'loads config from target directory' do
        expect(subject['user']).to eq('foo')
        expect(subject['password']).to eq('bar')
      end
    end

    context 'when the file exists in parent directory' do
      let(:target_dir) { contest_root }

      it 'loads config from parent directory' do
        expect(subject['user']).to eq('foo')
        expect(subject['password']).to eq('bar')
      end
    end

    context 'when the file does not exist' do
      let(:target_dir) { 'otherdir' }

      it 'loads config from default.xml' do
        expect(subject['user']).to be_empty
        expect(subject['password']).to be_empty
      end
    end
  end
end
