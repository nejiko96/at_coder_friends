# frozen_string_literal: true

RSpec.describe AtCoderFriends::TestRunner::Judge do
  include_context :atcoder_env

  subject(:runner) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, path) }
  let(:path) { File.join(contest_root, prog) }
  let(:prog) { 'A.rb' }

  describe '#judge_one' do
    subject { runner.judge_one(id) }
    let(:id) { '00_sample_1.txt' }

    context 'when the test case does not exist' do
      let(:id) { '00_sample_9.txt' }
      it 'shows error' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** judge_one A.rb (local) *****
            ==== 00_sample_9.txt ====
            00_sample_9.txt not found.
          OUTPUT
        ).to_stdout
        expect(subject).to be false
      end
    end

    context 'when test location is local and all tests are successfull' do
      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** judge_one A.rb (local) *****
            ==== 00_sample_1.txt ====
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
            ***** judge_one A.py (remote) *****
            ==== 00_sample_1.txt ====
            logged in as ねじこ (Contestant)
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

  describe '#judge_all' do
    subject { runner.judge_all }

    context 'when test location is local and all tests are successful' do
      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** judge_all A.rb (local) *****
            ==== 00_sample_1.txt ====
            \e[0;32;49m<< OK >>\e[0m
            ==== 00_sample_2.txt ====
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
            ***** judge_all A.py (remote) *****
            ==== 00_sample_1.txt ====
            logged in as ねじこ (Contestant)
            Exit code: 0
            Time: 17ms
            Memory: 5536KB
            \e[0;32;49m<< OK >>\e[0m
            ==== 00_sample_2.txt ====
            Exit code: 0
            Time: 17ms
            Memory: 5536KB
            \e[0;31;49m!!!!! WA !!!!!\e[0m
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
