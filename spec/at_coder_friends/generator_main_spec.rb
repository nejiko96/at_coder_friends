# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::Main do
  include FileHelper

  subject(:generator) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, target_dir) }

  describe '#process' do
    include_context :uses_temp_dir

    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:target_dir) { temp_dir }

    def ext_list
      pbm.sources.map(&:ext)
    end

    def create_config(config)
      create_file(
        File.join(temp_dir, '.at_coder_friends.yml'),
        config
      )
    end

    context 'with default configuration' do
      it 'generates Ruby and C++ source' do
        subject
        expect(ext_list).to match %i[rb cxx]
      end
    end

    context 'when Ruby generator is specified' do
      before :each do
        create_config(
          <<~TEXT
            generators:
              - RubyBuiltin
          TEXT
        )
      end

      it 'generates only Ruby source' do
        subject
        expect(ext_list).to match %i[rb]
      end
    end

    context 'when C++ generator is specified' do
      before :each do
        create_config(
          <<~TEXT
            generators:
              - CxxBuiltin
          TEXT
        )
      end

      it 'generates only C++ source' do
        subject
        expect(ext_list).to match %i[cxx]
      end
    end

    context 'when generator is not specified' do
      before :each do
        create_config(
          <<~TEXT
            generators: ~
          TEXT
        )
      end

      it 'does not generate any source' do
        subject
        expect(ext_list).to match []
      end
    end

    context 'when specified generator does not exist' do
      before :each do
        create_config(
          <<~TEXT
            generators:
              - RubyAlternative
          TEXT
        )
      end

      it 'shows error' do
        expect { subject }.to raise_error(
          AtCoderFriends::AppError,
          'plugin load error : generator RubyAlternative not found.'
        )
      end
    end
  end
end
