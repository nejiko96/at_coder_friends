# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::Main do
  include FileHelper

  include_context :uses_temp_dir

  subject(:generator) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, target_dir) }
  let(:target_dir) { temp_dir }

  def create_config(config)
    create_file(
      File.join(temp_dir, '.at_coder_friends.yml'),
      config
    )
  end

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }

    def ext_list
      pbm.sources.map(&:ext)
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

  describe '#load_obj' do
    subject { generator.load_obj('RubyBuiltin') }

    context 'with default configuration' do
      it 'initializes generator by empty setting' do
        expect(subject.cfg).to match({})
      end
    end

    context 'with generator configuration specified' do
      before :each do
        create_config(
          <<~TEXT
            generator_settings:
              RubyBuiltin:
                default_template: customized_default.rb
                interactive_template: customized_interactive.rb
          TEXT
        )
      end

      it 'initializes generator by specified setting' do
        expect(subject.cfg).to match(
          'default_template' => 'customized_default.rb',
          'interactive_template' => 'customized_interactive.rb'
        )
      end
    end
  end
end
