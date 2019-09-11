# frozen_string_literal: true

RSpec.describe AtCoderFriends::ConfigLoader do
  include FileHelper
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

    context 'when user setting overwrites default' do
      include_context :uses_temp_dir
      let(:target_dir) { temp_dir }
      before :each do
        create_file(
          File.join(temp_dir, '.at_coder_friends.yml'),
          <<~TEXT
            ext_settings:
              'cs':
                test_cmd: null
              'xxx':
                submit_lang: '9999'
          TEXT
        )
      end

      it 'merges user setting and default' do
        p subject
        expect(subject['ext_settings']['rb']).not_to eq nil
        expect(subject['ext_settings']['cs']['submit_lang']).not_to eq nil
        expect(subject['ext_settings']['cs']['test_cmd']).to eq nil
        expect(subject['ext_settings']['xxx']).not_to eq nil
      end
    end
  end
end
