# frozen_string_literal: true

RSpec.describe AtCoderFriends::CLI do
  include_context :atcoder_env

  subject(:cli) { described_class.new }

  USAGE = <<~TEXT
    Usage:
      at_coder_friends setup    path/contest       # setup contest folder
      at_coder_friends test-one path/contest/src   # run 1st test case
      at_coder_friends test-all path/contest/src   # run all test cases
      at_coder_friends submit   path/contest/src   # submit source code
    Options:
        -v, --version                    Display version.
  TEXT

  subject { cli.run(args) }
  describe 'exiting options' do
    context '-v' do
      let(:args) { ['-v'] }
      it 'shows version' do
        expect { subject }.to output("#{AtCoderFriends::VERSION}\n").to_stdout
        expect(subject).to eq(0)
      end
    end

    context '--version' do
      let(:args) { ['--version'] }
      it 'shows version' do
        expect { subject }.to output("#{AtCoderFriends::VERSION}\n").to_stdout
        expect(subject).to eq(0)
      end
    end

    context '-h' do
      let(:args) { ['-h'] }
      it 'shows usage' do
        expect { subject }.to output(USAGE).to_stdout
        expect(subject).to eq(0)
      end
    end

    context '--help' do
      let(:args) { ['--help'] }
      it 'shows usage' do
        expect { subject }.to output(USAGE).to_stdout
        expect(subject).to eq(0)
      end
    end
  end

  describe 'argument errors' do
    context 'when the option does not exist' do
      let(:args) { ['--nothing'] }
      it 'shows usage' do
        expect { subject }.to output(
          USAGE +
          "error: invalid option: --nothing\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when the number of arguments is wrong' do
      let(:args) { ['setup'] }
      it 'shows usage' do
        expect { subject }.to output(
          USAGE +
          "error: command or path is not specified.\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'with a wrong command' do
      let(:args) { ['init', contest_root] }
      it 'shows usage' do
        expect { subject }.to output(
          USAGE +
          "error: unknown command: init\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when config file is not found' do
      let(:args) { ['setup', '/foo/bar'] }
      it 'shows error' do
        expect { subject }.to output(
          "Configuration file not found: /foo/bar\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end
  end

  describe 'setup' do
    let(:args) { ['setup', path] }

    context 'when the folder exists' do
      let(:path) { contest_root }
      it 'shows error' do
        expect { subject }.to output(
          "#{contest_root} already exists.\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end
  end

  describe 'test-one' do
    let(:args) { ['test-one', path] }
  end

  describe 'test-all' do
    let(:args) { ['test-all', path] }
  end

  describe 'submit' do
    let(:args) { ['submit', path] }
    let(:path) { File.join(contest_root, src) }

    context 'when the source has not been tested' do
      let(:src) { 'A.rb' }
      it 'shows error' do
        expect { subject }.to output(
          "A.rb has not been tested.\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end
  end
end
