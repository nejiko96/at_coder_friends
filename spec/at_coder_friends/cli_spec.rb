# frozen_string_literal: true

RSpec.describe AtCoderFriends::CLI do
  include FileHelper

  include_context :atcoder_env

  subject(:cli) { described_class.new }
  let(:args) { [command, path] }
  let(:path) { File.join(contest_root, src) }
  let(:src) { 'A.rb' }

  after(:all) { rmdir_force(tmp_dir) }

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

    context 'with a unknown command' do
      let(:command) { 'init' }
      it 'shows usage' do
        expect { subject }.to output(
          USAGE +
          "error: unknown command: init\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when config file is not found' do
      let(:command) { 'setup' }
      let(:path) { '/foo/bar' }
      it 'shows error' do
        expect { subject }.to output(
          "Configuration file not found: /foo/bar\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end
  end

  describe 'setup' do
    let(:command) { 'setup' }
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
    let(:command) { 'test-one' }
    it 'runs 1st test case' do
      expect { subject }.to output(
        <<~OUTPUT
          ***** test_one A.rb *****
          ==== A_001 ====
          -- input --
          1
          2 3
          test
          -- expected --
          6 test
          -- result --
          6 test
          << OK >>
        OUTPUT
      ).to_stdout
    end
  end

  describe 'test-all' do
    let(:command) { 'test-all' }

    it 'runs all test cases' do
      expect { subject }.to output(
        <<~OUTPUT
          ***** test_all A.rb *****
          ==== A_001 ====
          -- input --
          1
          2 3
          test
          -- expected --
          6 test
          -- result --
          6 test
          << OK >>
          ==== A_002 ====
          -- input --
          72
          128 256
          myonmyon
          -- expected --
          456 myonmyon
          -- result --
          456 myonmyon
          << OK >>
        OUTPUT
      ).to_stdout
    end

    context 'if the source has not been tested' do
      let(:result_path) { File.join(tmp_dir, 'A.rb.verified') }
      before { rmdir_force(tmp_dir) }
      it 'mark the source as verified' do
        expect { subject }.to change { File.exist?(result_path) }
          .from(false).to(true)
      end
    end
  end

  describe 'submit' do
    let(:command) { 'submit' }
    context 'when the source has not been tested' do
      before { rmdir_force(tmp_dir) }
      it 'shows error' do
        expect { subject }.to output(
          "A.rb has not been tested.\n"
        ).to_stderr
        expect(subject).to eq(1)
      end
    end
  end
end
