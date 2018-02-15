# frozen_string_literal: true

RSpec.describe AtCoderFriends::CxxGenerator do
  subject(:generator) do
    described_class.new
  end

  describe '#gen_consts' do
    subject { generator.gen_consts(desc) }
    let(:desc) do
      <<~TEXT
        1 行目には、村の個数を表した整数 N (2 ≦ N ≦ 10^4) と、
        道の本数を表した整数 M (1 ≦ M ≦ 10^4) が空白区切りで与えられる。
        続く M 行には、道の情報が与えられる。
        このうちの i 行目には 4 つの整数
        A_i (0 ≦ A_i ≦ N-1), B_i (0 ≦ B_i ≦ N-1),
        C_i (1 ≤ C_i ≤ 10^6), T_i (1 leq T_i leq 10^6)
        が空白区切りで書かれており、これは 村 A_i と村 B_i を繋ぐ道があり、
        この道を修理するために費用が C_i、時間が T_i かかることを表している。
      TEXT
    end

    it 'generates constant decls' do
      expect(subject).to match_array(
        [
          'const int N_MAX = 10000;',
          'const int M_MAX = 10000;',
          'const int C_I_MAX = 1000000;',
          'const int T_I_MAX = 1000000;'
        ]
      )
    end
  end


end
