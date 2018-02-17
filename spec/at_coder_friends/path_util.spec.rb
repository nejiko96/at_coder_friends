# frozen_string_literal: true

RSpec.describe AtCoderFriends::PathUtil do
  subject(:path_util) { described_class }

  describe '#split_prg_path' do
    subject { path_util.split_prg_path(path) }
    let(:path) { '/foo/bar/contest/A_v2.rb' }

    it 'splits given path' do
      expect(subject).to match_array(
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
