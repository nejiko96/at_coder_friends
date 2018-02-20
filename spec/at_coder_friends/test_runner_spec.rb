# frozen_string_literal: true

RSpec.describe AtCoderFriends::TestRunner do
  include_context :atcoder_env

  subject(:runner) { described_class.new(File.join(contest_root, prog)) }
  let(:prog) { 'A.rb' }

  after(:all) { FileUtils.rm(Dir.glob(smp_dir + '/*.out')) }

  describe '#edit_cmd' do
    subject { runner.edit_cmd }

    context 'for .java' do
      let(:prog) { 'A.java' }
      it 'returns command' do
        expect(subject).to eq("java -cp #{contest_root} Main")
      end
    end

    context 'for .rb' do
      let(:prog) { 'A.rb' }
      it 'returns command' do
        expect(subject).to eq("ruby #{contest_root}/A.rb")
      end
    end

    context 'for .cs' do
      let(:prog) { 'A.cs' }

      context 'on Windows' do
        before do
          allow(runner).to receive(:which_os) { :windows }
        end

        it 'returns command' do
          expect(subject).to eq("#{contest_root}/A.exe")
        end
      end

      context 'on Mac' do
        before do
          allow(runner).to receive(:which_os) { :macosx }
        end
        it 'returns command' do
          expect(subject).to eq("mono #{contest_root}/A.exe")
        end
      end
    end

    context 'for others' do
      let(:prog) { 'A.cxx' }

      context 'on Windows' do
        before do
          allow(runner).to receive(:which_os) { :windows }
        end

        it 'returns command' do
          expect(subject).to eq("#{contest_root}/A.exe")
        end
      end

      context 'on Mac' do
        before do
          allow(runner).to receive(:which_os) { :macosx }
        end
        it 'returns command' do
          expect(subject).to eq("#{contest_root}/A")
        end
      end
    end
  end

  describe '#test' do
    subject { runner.test(no) }
    let(:no) { 1 }

    context 'when the test case exists' do
      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the test case does not exist' do
      let(:no) { 3 }
      it 'returns true' do
        expect(subject).to be false
      end
    end

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
            << OK >>
          OUTPUT
        ).to_stdout
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
            !!!!! WA !!!!!
          OUTPUT
        ).to_stdout
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
            !!!!! RE !!!!!
          OUTPUT
        ).to_stdout
      end
    end
  end

  describe '#test_one' do
    subject { runner.test_one(1) }

    it 'shows result' do
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

  describe '#test_all' do
    subject { runner.test_all }

    it 'shows result' do
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
end
