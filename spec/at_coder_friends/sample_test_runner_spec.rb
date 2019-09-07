# frozen_string_literal: true

RSpec.describe AtCoderFriends::SampleTestRunner do
  include_context :atcoder_env

  subject(:runner) do
    described_class.new(File.join(contest_root, prog), config)
  end
  let(:prog) { 'A.rb' }
  let(:config) { AtCoderFriends::ConfigLoader.load_config(contest_root) }

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
