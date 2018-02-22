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

      it 'show error message' do
        expect { subject }.to raise_error(
          AtCoderFriends::ConfigNotFoundError
        ) do |e|
          expect(e.message).to(match(/\AConfiguration file not found: .+\z/))
        end
      end
    end
  end
end
