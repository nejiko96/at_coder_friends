# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::ConstraintsParser do
  subject(:parser) do
    described_class
  end

  describe '#parse' do
    subject { parser.parse(desc) }

    context 'normal case' do
      let(:desc) do
        <<~DESC
          1 行目には、村の個数を表した整数 N (2 ≦ N ≦ 10^4) と、
          道の本数を表した整数 M (1 ≦ M ≦ 10^4) が空白区切りで与えられる。
          続く M 行には、道の情報が与えられる。
          このうちの i 行目には 4 つの整数
          A_i (0 ≦ A_i ≦ N-1), B_i (0 ≦ B_i ≤ N-1),
          C_i (1 ≤ C_i leq 10^6), T_i (1 leq T_i le 10^6)
          が空白区切りで書かれており、これは 村 A_i と村 B_i を繋ぐ道があり、
          この道を修理するために費用が C_i、時間が T_i かかることを表している。
        DESC
      end

      it 'parses constraints' do
        expect(subject.size).to eq(4)
        expect(subject[0].name).to eq('N')
        expect(subject[0].value).to eq(10_000)
        expect(subject[1].name).to eq('M')
        expect(subject[1].value).to eq(10_000)
        expect(subject[2].name).to eq('C_i')
        expect(subject[2].value).to eq(1_000_000)
        expect(subject[3].name).to eq('T_i')
        expect(subject[3].value).to eq(1_000_000)
      end
    end
  end
end
