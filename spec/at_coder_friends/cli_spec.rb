# frozen_string_literal: true

RSpec.describe AtCoderFriends::CLI do
  subject(:cli) { described_class.new }

  subject { cli.run(args) }
  describe 'exiting options' do
    context '-v' do
      let(:args) { ['-v'] }
      it 'shows version' do
        expect { subject }.to output("0.1.0\n").to_stdout
        expect(subject).to eq(0)
      end
    end

    context '--version' do
      let(:args) { ['--version'] }
      it 'shows version' do
        expect { subject }.to output("0.1.0\n").to_stdout
        expect(subject).to eq(0)
      end
    end

    context '-h' do
      let(:args) { ['-h'] }
      it 'shows usage' do
        expect { subject }.to output(
          <<~OUTPUT
            Usage: at_coder_friends [options] [command] [path]
                -v, --version                    Display version.
          OUTPUT
        ).to_stdout
        expect(subject).to eq(0)
      end
    end

    context '--help' do
      let(:args) { ['--help'] }
      it 'shows usage' do
        expect { subject }.to output(
          <<~OUTPUT
            Usage: at_coder_friends [options] [command] [path]
                -v, --version                    Display version.
          OUTPUT
        ).to_stdout
        expect(subject).to eq(0)
      end
    end
  end

  describe 'argument errors' do
    context 'when the option does not exist' do
      let(:args) { ['--nothing'] }
      it 'shows usage' do
        expect { subject }.to output(
          <<~OUTPUT
            Usage: at_coder_friends [options] [command] [path]
                -v, --version                    Display version.
            error: invalid option: --nothing
          OUTPUT
        ).to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when the number of arguments is wrong' do
      let(:args) { ['setup'] }
      it 'shows usage' do
        expect { subject }.to output(
          <<~OUTPUT
            Usage: at_coder_friends [options] [command] [path]
                -v, --version                    Display version.
            error: command or path is not specified.
          OUTPUT
        ).to_stderr
        expect(subject).to eq(1)
      end
    end
  end
end
