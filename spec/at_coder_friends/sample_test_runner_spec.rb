# frozen_string_literal: true

RSpec.describe AtCoderFriends::TestRunner::Sample do
  include_context :atcoder_env

  subject(:runner) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, path) }
  let(:path) { File.join(contest_root, prog) }
  let(:prog) { 'A.rb' }

  describe '#test_one' do
    subject { runner.test_one(id) }
    let(:id) { '001' }

    context 'when the test case does not exist' do
      let(:id) { '999' }
      it 'shows error' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** test_one A.rb (local) *****
            ==== A_999 ====
            A_999.in not found.
          OUTPUT
        ).to_stdout
        expect(subject).to be false
      end
    end

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
            \e[0;32;49m<< OK >>\e[0m
          OUTPUT
        ).to_stdout
        expect(subject).to be true
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
            \e[0;32;49m<< OK >>\e[0m
          OUTPUT
        ).to_stdout
        expect(subject).to be true
      end
    end
  end

  describe '#test_all' do
    subject { runner.test_all }

    context 'when test location is local and all tests are successful' do
      before(:all) do
        File.rename(
          File.join(smp_dir, 'A_add_2.exp'),
          File.join(smp_dir, 'A_add_1.exp')
        )
      end

      after(:all) do
        File.rename(
          File.join(smp_dir, 'A_add_1.exp'),
          File.join(smp_dir, 'A_add_2.exp')
        )
      end

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
            \e[0;32;49m<< OK >>\e[0m
            ==== A_002 ====
            -- input --
            72
            128 256
            myonmyon
            -- expected --
            456 myonmyon
            -- result --
            456 myonmyon
            \e[0;32;49m<< OK >>\e[0m
            ==== A_add_1 ====
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

    context 'when test location is remote and some tests fails' do
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
            \e[0;32;49m<< OK >>\e[0m
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
            \e[0;31;49m!!!!! WA !!!!!\e[0m
            ==== A_add_1 ====
            Exit code: 0
            Time: 17ms
            Memory: 5536KB
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

    context 'when there is no test cases' do
      let(:prog) { 'B.rb' }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
