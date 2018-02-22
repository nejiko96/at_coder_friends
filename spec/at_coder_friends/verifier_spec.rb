# frozen_string_literal: true

RSpec.describe AtCoderFriends::Verifier do
  include FileHelper

  include_context :atcoder_env

  subject(:verifier) { described_class.new(target_path) }
  let(:target_path) { File.join(contest_root, target_file) }
  let(:result_path) { File.join(contest_root, result_file) }
  let(:target_file) { 'A.rb' }
  let(:result_file) { '.tmp/A.rb.verified' }

  describe '#verify' do
    subject { verifier.verify }

    context 'when the target exists' do
      it 'creates .verified file' do
        expect { subject }.to change { File.exist?(result_path) }
          .from(false).to(true)
      end
    end

    context 'when the target does not exist' do
      let(:target_file) { 'nothing.rb' }
      it 'does not create .verified' do
        expect { subject }
          .not_to change { Dir.exist?(tmp_dir) && Dir.entries(tmp_dir).size }
      end
    end
  end

  describe '#unverify' do
    subject { verifier.unverify }

    context 'when .verified exists' do
      before { create_file(result_path, '') }

      it 'removes .verified' do
        expect { subject }.to change { File.exist?(result_path) }
          .from(true).to(false)
      end
    end

    context 'when .verified does not exist' do
      it 'does not remove .verified' do
        expect { subject }
          .not_to change { Dir.exist?(tmp_dir) && Dir.entries(tmp_dir).size }
      end
    end
  end

  describe '#verified?' do
    subject { verifier.verified? }

    context 'when the target is verified' do
      before do
        create_file(File.join(contest_root, result_file), '')
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the target is not verified' do
      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when the target is modified after verified' do
      before do
        create_file(result_path, '')
        sleep 1
        FileUtils.touch(target_path)
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
