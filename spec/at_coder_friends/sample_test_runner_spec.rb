# frozen_string_literal: true

RSpec.describe AtCoderFriends::TestRunner::Sample do
  include_context :atcoder_env

  subject(:runner) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, path) }
  let(:path) { File.join(contest_root, prog) }
  let(:prog) { 'A.rb' }

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
      it 'returns false' do
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
  end

  describe '#test_one' do
    subject { runner.test_one(1) }

    context 'when test location is local' do
      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** test_one A.rb (local) *****
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

    context 'when test location is remote' do
      include_context :atcoder_stub
      let(:prog) { 'A.py' }

      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** test_one A.py (remote) *****
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
            << OK >>
          OUTPUT
        ).to_stdout
      end
    end
  end

  describe '#test_all' do
    subject { runner.test_all }

    context 'when test location is local' do
      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** test_all A.rb (local) *****
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

    context 'when test location is remote' do
      include_context :atcoder_stub
      let(:prog) { 'A.py' }

      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** test_all A.py (remote) *****
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
            << OK >>
            ==== A_002 ====
            Exit code: 0
            Time: 17ms
            Memory: 5536KB
            -- input --
            72
            128 256
            myonmyon
            -- expected --
            456 myonmyon
            -- result --
            6 test
            !!!!! WA !!!!!
          OUTPUT
        ).to_stdout
      end
    end
  end
end
