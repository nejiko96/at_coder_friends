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
        expect { subject }.to output(
          Regexp.compile(
            Regexp.escape(
              <<~MSG
                an error occurred in generator:RubyAlternative.
                Error: Failed to load plugin.
                The 'RubyAlternative' plugin could not be found. To use this plugin, please install the required gem by following these steps:

                1. Open a terminal or command prompt.
                2. Run the following command:
                   gem install at_coder_friends-generator-ruby_alternative
                3. Once the above command completes, please run the program again.
              MSG
            )
          )
        ).to_stdout
      end
    end

    context 'when Ruby generation failed' do
      before do
        allow_any_instance_of(AtCoderFriends::Generator::RubyBuiltin)
          .to receive(:process).and_raise(StandardError.new('error'))
      end
      it 'shows error' do
        expect { subject }.to output(
          Regexp.compile(
            Regexp.escape(
              <<~MSG
                an error occurred in generator:RubyBuiltin.
                error
              MSG
            )
          )
        ).to_stdout
      end

      it 'generates C++ source' do
        subject
        expect(ext_list).to match %i[cxx]
      end
    end

    context 'when C++ generation failed' do
      before do
        allow_any_instance_of(AtCoderFriends::Generator::CxxBuiltin)
          .to receive(:process).and_raise(StandardError.new('error'))
      end
      it 'shows error' do
        expect { subject }.to output(
          Regexp.compile(
            Regexp.escape(
              <<~MSG
                an error occurred in generator:CxxBuiltin.
                error
              MSG
            )
          )
        ).to_stdout
      end

      it 'generates Ruby source' do
        subject
        expect(ext_list).to match %i[rb]
      end
    end
  end

  describe '#load_obj' do
    subject { generator.load_obj(gen_name) }
    let(:gen_name) { 'RubyBuiltin' }

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
          TEXT
        )
      end

      it 'initializes generator by specified setting' do
        expect(subject.cfg).to match(
          'default_template' => 'customized_default.rb'
        )
      end
    end

    context 'with generator name contains separator' do
      let(:gen_name) { 'RubyBuiltin_1' }
      before :each do
        create_config(
          <<~TEXT
            generator_settings:
              RubyBuiltin_1:
                default_template: customized_default.rb
          TEXT
        )
      end

      it 'takes class name from the first token' do
        expect(subject).to be_an_instance_of(
          AtCoderFriends::Generator::RubyBuiltin
        )
      end

      it 'takes generator settings by full name' do
        expect(subject.cfg).to match(
          'default_template' => 'customized_default.rb'
        )
      end
    end
  end
end
