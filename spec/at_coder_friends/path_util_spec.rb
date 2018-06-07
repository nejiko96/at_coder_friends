# frozen_string_literal: true

RSpec.describe AtCoderFriends::PathUtil do
  include_context :atcoder_env

  subject(:path_util) { described_class }

  describe '#contest_name' do
    subject { path_util.contest_name(path) }

    context 'from file' do
      let(:path) { File.join(contest_root, 'A.rb') }

      it 'returns contest name' do
        expect(subject).to eq('arc001')
      end
    end

    context 'from directory' do
      let(:path) { contest_root }

      it 'returns contest name' do
        expect(subject).to eq('arc001')
      end
    end
  end

  describe '#split_prg_path' do
    subject { path_util.split_prg_path(path) }
    let(:path) { '/foo/bar/contest/A_v2.rb' }

    it 'splits given path' do
      expect(subject).to match(
        [
          '/foo/bar/contest/A_v2.rb',
          '/foo/bar/contest',
          'A_v2.rb',
          'A_v2',
          'rb',
          'A'
        ]
      )
    end
  end

  describe '#smp_dir' do
    subject { path_util.smp_dir(path) }
    let(:path) { '/foo/bar/contest' }

    it 'returns samples directory' do
      expect(subject).to eq('/foo/bar/contest/data')
    end
  end

  describe '#cases_dir' do
    subject { path_util.cases_dir(path) }
    let(:path) { '/foo/bar/contest' }

    it 'returns cases directory' do
      expect(subject).to eq('/foo/bar/contest/cases')
    end
  end
end
