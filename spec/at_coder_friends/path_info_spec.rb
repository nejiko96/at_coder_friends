# frozen_string_literal: true

RSpec.describe AtCoderFriends::PathInfo do
  include_context :atcoder_env

  subject(:path_info) { described_class.new(path) }

  describe '#contest_name' do
    subject { path_info.contest_name }

    context 'from file' do
      let(:path) { File.join(contest_root, 'A.rb') }

      it 'returns contest name' do
        expect(subject).to eq('practice')
      end
    end

    context 'from directory' do
      let(:path) { contest_root }

      it 'returns contest name' do
        expect(subject).to eq('practice')
      end
    end
  end

  describe '#components' do
    subject { path_info.components }
    let(:path) { File.join(contest_root, 'A_v2.rb') }

    it 'splits given path' do
      expect(subject).to match(
        [
          path,
          contest_root,
          'A_v2.rb',
          'A_v2',
          'rb',
          'A'
        ]
      )
    end
  end

  describe '#src_dir' do
    subject { path_info.src_dir }
    let(:path) { '/foo/bar/contest' }

    it 'returns samples directory' do
      expect(subject).to eq('/foo/bar/contest')
    end
  end

  describe '#smp_dir' do
    subject { path_info.smp_dir }
    let(:path) { '/foo/bar/contest' }

    it 'returns samples directory' do
      expect(subject).to eq('/foo/bar/contest/data')
    end
  end

  describe '#cases_dir' do
    subject { path_info.cases_dir }
    let(:path) { '/foo/bar/contest' }

    it 'returns cases directory' do
      expect(subject).to eq('/foo/bar/contest/cases')
    end
  end

  describe '#cases_out_dir' do
    subject { path_info.cases_out_dir }
    let(:path) { '/foo/bar/contest' }

    it 'returns cases directory' do
      expect(subject).to eq('/foo/bar/contest/.tmp/cases')
    end
  end
end
