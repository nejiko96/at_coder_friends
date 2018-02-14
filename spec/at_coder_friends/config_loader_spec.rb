# frozen_string_literal: true

RSpec.describe AtCoderFriends::ConfigLoader do
  include FileHelper

  spec_root = File.expand_path('..', __dir__)
  project_root = File.join(spec_root, 'fixtures/project')
  contest_root = File.join(project_root, 'contest')

  describe '#load_config' do
    subject(:load_config) do
      described_class.load_config(target_dir)
    end

    context 'when the file exists in target directory' do
      let(:target_dir) { project_root }
      it 'loads config from target directory' do
        expect(load_config['user']).to eq('foo')
        expect(load_config['password']).to eq('bar')
      end
    end

    context 'when the file exists in parent directory' do
      let(:target_dir) { contest_root }

      it 'loads config from parent directory' do
        expect(load_config['user']).to eq('foo')
        expect(load_config['password']).to eq('bar')
      end
    end

    context 'when the file does not exist' do
      let(:target_dir) { 'otherdir' }

      it 'show error message' do
        expect { load_config }.to raise_error(
          AtCoderFriends::ConfigNotFoundError
        ) do |e|
          expect(e.message).to(match(/\AConfiguration file not found: .+\z/))
        end
      end
    end
  end
end
