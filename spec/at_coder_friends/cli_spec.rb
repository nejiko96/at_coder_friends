# frozen_string_literal: true

RSpec.describe AtCoderFriends::CLI do
  include FileHelper
  include_context :atcoder_env

  subject(:cli) { described_class.new }
  let(:args) { [command, path] }
  let(:path) { File.join(contest_root, src) }
  let(:src) { 'A.rb' }

  USAGE = <<~TEXT
    Usage:
      at_coder_friends setup        path/contest       # setup contest folder
      at_coder_friends test-one     path/contest/src   # run 1st test case
      at_coder_friends test-all     path/contest/src   # run all test cases
      at_coder_friends submit       path/contest/src   # submit source code
      at_coder_friends open-contest path/contest/src   # open contest page
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
        expect { subject }.to \
          output(USAGE + "error: invalid option: --nothing\n").to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when the number of arguments is wrong' do
      let(:args) { ['setup'] }
      it 'shows usage' do
        expect { subject }.to \
          output(USAGE + "error: command or path is not specified.\n")
          .to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'with a unknown command' do
      let(:command) { 'init' }
      it 'shows usage' do
        expect { subject }.to \
          output(USAGE + "error: unknown command: init\n").to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when config file is not found' do
      let(:command) { 'setup' }
      let(:path) { '/foo/bar' }
      it 'shows error' do
        expect { subject }.to \
          output("Configuration file not found: /foo/bar\n").to_stderr
        expect(subject).to eq(1)
      end
    end
  end

  describe 'setup' do
    let(:command) { 'setup' }

    context 'when the folder is not empty' do
      let(:path) { contest_root }
      it 'shows error' do
        expect { subject }.to \
          output("#{contest_root} is not empty.\n").to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when there is no error' do
      include_context :uses_temp_dir
      include_context :atcoder_stub

      let(:path) { File.join(temp_dir, 'practice') }
      before :each do
        create_file(
          File.join(temp_dir, '.at_coder_friends.yml'),
          <<~TEXT
            user: foo
            password: bar
          TEXT
        )
      end
      let(:f) { ->(file) { File.join(path, file) } }
      let(:e) { ->(file) { File.exist?(f[file]) } }

      shared_examples 'normal case' do
        it 'generates examples and sources' do
          expect { subject }.to output(
            <<~OUTPUT
              ***** fetch_all practice *****
              fetch list from https://atcoder.jp/contests/practice/tasks ...
              fetch problem from /contests/practice/tasks/practice_1 ...
              A_001.in
              A_001.exp
              A_002.in
              A_002.exp
              A.rb
              A.cxx
              fetch problem from /contests/practice/tasks/practice_2 ...
              B.rb
              B.cxx
            OUTPUT
          ).to_stdout
          expect(e['data/A_001.in']).to be true
          expect(e['data/A_001.exp']).to be true
          expect(e['data/A_002.in']).to be true
          expect(e['data/A_002.exp']).to be true
          expect(e['A.rb']).to be true
          expect(e['A.cxx']).to be true
          expect(e['B.rb']).to be true
          expect(e['B.cxx']).to be true
        end
      end

      context 'when the folder does not exist' do
        it_behaves_like 'normal case'
      end

      context 'when the folder is empty' do
        before { Dir.mkdir(path) }
        it_behaves_like 'normal case'
      end
    end
  end

  describe 'test-one' do
    let(:command) { 'test-one' }

    context 'if the test no. is not specified' do
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

    context 'if the test no. is specified' do
      let(:args) { [command, path, id] }
      let(:id) { '2' }

      it 'runs specified test case' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** test_one A.rb *****
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
  end

  describe 'judge-one' do
    let(:args) { [command, path, id] }
    let(:command) { 'judge-one' }
    let(:id) { '00_sample_1' }

    it 'runs specified test case' do
      expect { subject }.to output(
        <<~OUTPUT
          ***** judge_one A.rb *****
          ==== 00_sample_1 ====
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

  describe 'judge-all' do
    let(:command) { 'judge-all' }

    it 'runs all test cases' do
      expect { subject }.to output(
        <<~OUTPUT
          ***** judge_all A.rb *****
          ==== 00_sample_1 ====
          -- input --
          1
          2 3
          test
          -- expected --
          6 test
          -- result --
          6 test
          << OK >>
          ==== 00_sample_2 ====
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
  end

  describe 'submit' do
    let(:command) { 'submit' }

    context 'when the source has not been tested' do
      it 'shows error' do
        expect { subject }.to \
          output("A.rb has not been tested.\n").to_stderr
        expect(subject).to eq(1)
      end
    end

    context 'when there is no error' do
      include_context :atcoder_stub

      let(:vf_path) { File.join(tmp_dir, 'A.rb.verified') }

      before { AtCoderFriends::Verifier.new(path).verify }

      it 'posts the source' do
        expect { subject }.to \
          output("***** submit A.rb *****\n").to_stdout
      end

      it 'mark the source as unverified' do
        expect { subject }.to \
          change { File.exist?(vf_path) }.from(true).to(false)
      end
    end
  end
end
