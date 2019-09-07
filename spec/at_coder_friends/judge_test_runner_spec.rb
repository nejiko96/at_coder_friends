# frozen_string_literal: true

RSpec.describe AtCoderFriends::JudgeTestRunner do
  include_context :atcoder_env

  subject(:runner) do
    described_class.new(File.join(contest_root, prog), config)
  end
  let(:prog) { 'A.rb' }
  let(:config) { AtCoderFriends::ConfigLoader.load_config(contest_root) }

  describe '#judge' do
    subject { runner.judge(id) }
    let(:id) { '00_sample_1' }
    context 'when the test case exists' do
      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the test case does not exist' do
      let(:id) { '00_sample_9' }
      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when the result is OK' do
      it 'shows result' do
        expect { subject }.to output(
          <<~OUTPUT
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
  end

  describe '#judge_one' do
    subject { runner.judge_one('00_sample_1') }

    it 'shows result' do
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

  describe '#judge_all' do
    subject { runner.judge_all }

    it 'shows result' do
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
end
