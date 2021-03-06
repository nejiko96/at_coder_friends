# frozen_string_literal: true

RSpec.describe AtCoderFriends::ConfigLoader do
  include FileHelper
  include_context :atcoder_env

  subject(:loader) { described_class }

  describe '#load_config' do
    subject { loader.load_config(ctx) }
    let(:ctx) { AtCoderFriends::Context.new({}, target_dir) }

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
        expect(subject['user']).to be nil
        expect(subject['password']).to be nil
        expect(subject['ext_settings']['rb']).not_to be nil
      end
    end

    context 'default config' do
      include_context :atcoder_stub
      let(:target_dir) { contest_root }

      it 'maps each extension to proper language' do
        lst = ctx.scraping_agent.lang_list
        subject['ext_settings'].each do |ext, conf|
          lang_ids = [conf['submit_lang']].flatten
          lang_name = lst.find { |opt| lang_ids.include?(opt[:v]) }&.fetch(:t)
          puts "#{ext} -> #{lang_name}"
        end
        # puts lst.map { |opt| "|#{opt[:v]}|#{opt[:t]}|" }.join("\n")
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
                test_cmd: ~
              'zzz':
                submit_lang: '9999'
          TEXT
        )
      end

      it 'merges user setting and default' do
        expect(subject['ext_settings']['rb']).not_to be nil
        expect(subject['ext_settings']['cs']['submit_lang']).not_to be nil
        expect(subject['ext_settings']['cs']['test_cmd']).to be nil
        expect(subject['ext_settings']['zzz']).not_to be nil
      end
    end

    context 'when user setting is empty' do
      include_context :uses_temp_dir
      let(:target_dir) { temp_dir }
      before :each do
        create_file(File.join(temp_dir, '.at_coder_friends.yml'), '')
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
