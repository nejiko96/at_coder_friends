# frozen_string_literal: true

RSpec.describe AtCoderFriends::Verifier do
  include FileHelper

  spec_root = File.expand_path('..', __dir__)
  contest_root = File.join(spec_root, 'fixtures/project/contest')
  tmpdir = File.join(contest_root, '.tmp')

  subject(:verifier) { described_class.new(target_path) }
  let(:target_path) { File.join(contest_root, target_file) }
  let(:result_path) { File.join(tmpdir, "#{target_file}.verified") }

  before :each do
    rmdir_force(tmpdir)
  end

  after :all do
    rmdir_force(tmpdir)
  end

  describe '#verify' do
    subject { verifier.verify }

    context 'when the target exists' do
      let(:target_file) { 'A.rb' }
      it 'creates .verified file' do
        expect { subject }.to change { File.exist?(result_path) }
          .from(false).to(true)
      end
    end

    context 'when the target does not exist' do
      let(:target_file) { 'not_exist.rb' }
      it 'does not create .verified' do
        expect { subject }.not_to change { File.exist?(result_path) }
      end
    end
  end

  describe '#unverify' do
    subject { verifier.unverify }

    context 'when .verified exists' do
      let(:target_file) { 'A.rb' }
      before { verifier.verify }
      it 'removes .verified' do
        expect { subject }.to change { File.exist?(result_path) }
          .from(true).to(false)
      end
    end

    context 'when .verified does not exist' do
      let(:target_file) { 'A.rb' }
      it 'does not remove .verified' do
        expect { subject }.not_to change { File.exist?(result_path) }
      end
    end
  end

  describe '#verified?' do
    subject { verifier.verified? }

    context 'when the target is verified' do
      let(:target_file) { 'A.rb' }
      before do
        create_file(File.join(tmpdir, 'A.rb.verified'), '')
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the target is not verified' do
      let(:target_file) { 'A.rb' }

      it 'returns false' do
        expect(subject).to be false
      end

      it 'shows message' do
        expect { subject }.to output("A.rb is not verified.\n")
          .to_stdout
      end
    end

    context 'when the target is modified after verified' do
      let(:target_file) { 'A.rb' }
      before do
        create_file(File.join(tmpdir, 'A.rb.verified'), '')
        sleep 1
        FileUtils.touch(File.join(contest_root, 'A.rb'))
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
