# frozen_string_literal: true

RSpec.describe AtCoderFriends::Verifier do
  include FileHelper

  spec_root = File.expand_path('..', __dir__)
  contest_root = File.join(spec_root, 'fixtures/project/contest')
  tmpdir = File.join(contest_root, '.tmp')

  subject(:verifier) { described_class.new(target_path) }
  let(:target_path) { File.join(contest_root, target_file) }
  let(:result_path) { File.join(contest_root, result_file) }
  let(:target_file) { 'A.rb' }
  let(:result_file) { '.tmp/A.rb.verified' }

  before :each do
    rmdir_force(tmpdir)
  end

  after :all do
    rmdir_force(tmpdir)
  end

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
          .not_to change { Dir.exist?(tmpdir) && Dir.entries(tmpdir).size }
      end
    end
  end

  describe '#unverify' do
    subject { verifier.unverify }

    context 'when .verified exists' do
      before do
        create_file(File.join(contest_root, result_file), '')
      end
      it 'removes .verified' do
        expect { subject }.to change { File.exist?(result_path) }
          .from(true).to(false)
      end
    end

    context 'when .verified does not exist' do
      it 'does not remove .verified' do
        expect { subject }
          .not_to change { Dir.exist?(tmpdir) && Dir.entries(tmpdir).size }
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

      it 'shows message' do
        expect { subject }.to output("A.rb is not verified.\n")
          .to_stdout
      end
    end

    context 'when the target is modified after verified' do
      before do
        create_file(File.join(contest_root, result_file), '')
        sleep 1
        FileUtils.touch(File.join(contest_root, target_file))
      end

      it 'returns false' do
        expect(subject).to be false
      end

      it 'shows message' do
        expect { subject }.to output("A.rb is not verified.\n")
          .to_stdout
      end
    end
  end
end
