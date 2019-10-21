# frozen_string_literal: true

RSpec.describe AtCoderFriends::TestRunner::Base do
  include_context :atcoder_env

  subject(:runner) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, path) }
  let(:path) { File.join(contest_root, prog) }
  let(:prog) { 'A.rb' }

  describe '#test_cmd' do
    subject { runner.test_cmd }

    context 'for .c' do
      let(:prog) { 'A.c' }

      context 'on Windows' do
        before do
          allow(runner).to receive(:which_os) { :windows }
        end
        it 'returns command' do
          expect(subject).to eq("\"#{contest_root}/A.exe\"")
        end
      end

      context 'on Mac' do
        before do
          allow(runner).to receive(:which_os) { :macosx }
        end
        it 'returns command' do
          expect(subject).to eq("\"#{contest_root}/A\"")
        end
      end
    end

    context 'for .cs' do
      let(:prog) { 'A.cs' }

      context 'on Windows' do
        before do
          allow(runner).to receive(:which_os) { :windows }
        end

        it 'returns command' do
          expect(subject).to eq("\"#{contest_root}/A.exe\"")
        end
      end

      context 'on Mac' do
        before do
          allow(runner).to receive(:which_os) { :macosx }
        end

        it 'returns command' do
          expect(subject).to eq("mono \"#{contest_root}/A.exe\"")
        end
      end
    end

    context 'for .cxx' do
      let(:prog) { 'A.cxx' }

      context 'on Windows' do
        before do
          allow(runner).to receive(:which_os) { :windows }
        end
        it 'returns command' do
          expect(subject).to eq("\"#{contest_root}/A.exe\"")
        end
      end

      context 'on Mac' do
        before do
          allow(runner).to receive(:which_os) { :macosx }
        end
        it 'returns command' do
          expect(subject).to eq("\"#{contest_root}/A\"")
        end
      end
    end

    context 'for .java' do
      let(:prog) { 'A.java' }
      it 'returns command' do
        expect(subject).to eq("java -cp \"#{contest_root}\" Main")
      end
    end

    context 'for .rb' do
      let(:prog) { 'A.rb' }
      it 'returns command' do
        expect(subject).to eq("ruby \"#{contest_root}/A.rb\"")
      end
    end

    context 'extension without test_cmd setting' do
      let(:prog) { 'A.py' }

      it 'returns nil' do
        expect(subject).to eq nil
      end
    end
  end

  describe '#run_test' do
    subject { runner.run_test(id, infile, outfile, expfile) }
    let(:infile) { "#{smp_dir}/#{id}.in" }
    let(:outfile) { "#{smp_dir}/#{id}.out" }
    let(:expfile) { "#{smp_dir}/#{id}.exp" }
    let(:id) { 'A_001' }

    context 'when the input file does not exist' do
      let(:id) { 'A_add_2' }
      it 'shows error' do
        expect { subject }.to output(
          <<~OUTPUT
            ==== A_add_2 ====
            A_add_2.in not found.
          OUTPUT
        ).to_stdout
        expect(subject).to be false
      end
    end

    context 'when the expected value file does not exist' do
      let(:id) { 'A_add_1' }
      it 'shows error' do
        expect { subject }.to output(
          <<~OUTPUT
            ==== A_add_1 ====
            -- input --
            1
            2 3
            test
            -- expected --
            (no expected value)
            -- result --
            6 test

          OUTPUT
        ).to_stdout
        expect(subject).to be false
      end
    end

    context 'extension with test_cmd setting' do
      context 'when the result is OK' do
        it 'shows result' do
          expect { subject }.to output(
            <<~OUTPUT
              ==== A_001 ====
              -- input --
              1
              2 3
              test
              -- expected --
              6 test
              -- result --
              6 test
              \e[0;32;49m<< OK >>\e[0m
            OUTPUT
          ).to_stdout
          expect(subject).to be true
        end
      end

      context 'when the result is WA' do
        let(:prog) { 'A_WA.rb' }

        it 'shows result' do
          expect { subject }.to output(
            <<~OUTPUT
              ==== A_001 ====
              -- input --
              1
              2 3
              test
              -- expected --
              6 test
              -- result --
              6_test
              \e[0;31;49m!!!!! WA !!!!!\e[0m
            OUTPUT
          ).to_stdout
          expect(subject).to be false
        end
      end

      context 'when the result is RE' do
        let(:prog) { 'A_RE.rb' }

        it 'shows result' do
          expect { subject }.to output(
            <<~OUTPUT
              ==== A_001 ====
              -- input --
              1
              2 3
              test
              -- expected --
              6 test
              -- result --
              \e[0;31;49m!!!!! RE !!!!!\e[0m
            OUTPUT
          ).to_stdout
          expect(subject).to be false
        end
      end
    end

    context 'extension without test_cmd setting' do
      include_context :atcoder_stub

      context 'when the result is OK' do
        let(:prog) { 'A.py' }

        it 'shows result' do
          expect { subject }.to output(
            <<~OUTPUT
              ==== A_001 ====
              Logged in as foo (Contestant)
              Exit code: 0
              Time: 17ms
              Memory: 5536KB
              -- input --
              1
              2 3
              test
              -- expected --
              6 test
              -- result --
              6 test
              \e[0;32;49m<< OK >>\e[0m
            OUTPUT
          ).to_stdout
          expect(subject).to be true
        end
      end

      context 'when the result is WA' do
        let(:prog) { 'A_WA.py' }
        let(:test_result) { 'WA' }

        it 'shows result' do
          expect { subject }.to output(
            <<~OUTPUT
              ==== A_001 ====
              Logged in as foo (Contestant)
              Exit code: 0
              Time: 17ms
              Memory: 5536KB
              -- input --
              1
              2 3
              test
              -- expected --
              6 test
              -- result --
              6_test
              \e[0;31;49m!!!!! WA !!!!!\e[0m
            OUTPUT
          ).to_stdout
          expect(subject).to be false
        end
      end

      context 'when the result is RE' do
        let(:prog) { 'A_RE.py' }
        let(:test_result) { 'RE' }

        it 'shows result' do
          expect { subject }.to output(
            <<~OUTPUT
              ==== A_001 ====
              Logged in as foo (Contestant)
              Exit code: 256
              Time: 17ms
              Memory: 5524KB
              -- input --
              1
              2 3
              test
              -- expected --
              6 test
              -- result --
              Traceback (most recent call last):
                File "./Main.py", line 9, in <module>
                  print(ans)
              NameError: name 'ans' is not defined
              \e[0;31;49m!!!!! RE !!!!!\e[0m
            OUTPUT
          ).to_stdout
          expect(subject).to be false
        end
      end
    end
  end
end
