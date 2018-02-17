# frozen_string_literal: true

RSpec.describe AtCoderFriends::PathUtil do
  subject(:path_util) { described_class }

  spec_root = File.expand_path('..', __dir__)
  contest_root = File.join(spec_root, 'fixtures/project/ARC#001')

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
end
