# frozen_string_literal: true

RSpec.describe AtCoderFriends::CxxGenerator do
  subject(:generator) { described_class.new }

  describe '#gen_consts' do
    subject { generator.gen_consts(desc) }
    let(:desc) do
      <<~DESC
        1 行目には、村の個数を表した整数 N (2 ≦ N ≦ 10^4) と、
        道の本数を表した整数 M (1 ≦ M ≦ 10^4) が空白区切りで与えられる。
        続く M 行には、道の情報が与えられる。
        このうちの i 行目には 4 つの整数
        A_i (0 ≦ A_i ≦ N-1), B_i (0 ≦ B_i ≦ N-1),
        C_i (1 ≤ C_i ≤ 10^6), T_i (1 leq T_i leq 10^6)
        が空白区切りで書かれており、これは 村 A_i と村 B_i を繋ぐ道があり、
        この道を修理するために費用が C_i、時間が T_i かかることを表している。
      DESC
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

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) { AtCoderFriends::InputDef.new(container, size, item, names) }
    let(:size) { nil }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A] }
      it 'generates decl' do
        expect(subject).to eq('int A;')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('int A, B;')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A] }
      it 'generates decl' do
        expect(subject).to match_array(['char A[A_MAX + 1];'])
      end
    end

    context 'for plain strings' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to match_array(
          [
            'char A[A_MAX + 1];',
            'char B[B_MAX + 1];'
          ]
        )
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:size) { 'N' }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('int A[N_MAX];')
      end
    end

    context 'for a horizontal array of numbers with size specified' do
      let(:container) { :harray }
      let(:size) { '10' }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('int A[10];')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:size) { 'N' }
      let(:item) { :string }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('char A[N_MAX][A_MAX + 1];')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:size) { 'N' }
      let(:item) { :char }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('char A[N_MAX + 1];')
      end
    end

    context 'for vertical array of numbers' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to match_array(
          [
            'int A[N_MAX];',
            'int B[N_MAX];'
          ]
        )
      end
    end

    context 'for vertical array of numbers with size specified' do
      let(:container) { :varray }
      let(:size) { '10' }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to match_array(
          [
            'int A[10];',
            'int B[10];'
          ]
        )
      end
    end

    context 'for vertical array of strings' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to match_array(
          [
            'char A[N_MAX][A_MAX + 1];',
            'char B[N_MAX][B_MAX + 1];'
          ]
        )
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('int A[R_MAX][C_MAX];')
      end
    end

    context 'for a matrix of numbers with size specified' do
      let(:container) { :matrix }
      let(:size) { %w[8 8] }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('int A[8][8];')
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :string }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('char A[R_MAX][C_MAX][A_MAX + 1];')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :char }
      let(:names) { 'A' }
      it 'generates decl' do
        expect(subject).to eq('char A[R_MAX][C_MAX + 1];')
      end
    end
  end

  describe '#gen_read' do
    subject { generator.gen_read(inpdef) }
    let(:inpdef) { AtCoderFriends::InputDef.new(container, size, item, names) }
    let(:size) { nil }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A] }
      it 'generates read script' do
        expect(subject).to eq('scanf("%d", &A);')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates read script' do
        expect(subject).to eq('scanf("%d%d", &A, &B);')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A] }
      it 'generates read script' do
        expect(subject).to eq('scanf("%s", A);')
      end
    end

    context 'for plain strings' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates read script' do
        expect(subject).to eq('scanf("%s%s", A, B);')
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:size) { 'N' }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates read script' do
        expect(subject).to eq('REP(i, N) scanf("%d", A + i);')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:size) { 'N' }
      let(:item) { :string }
      let(:names) { 'A' }
      it 'generates read script' do
        expect(subject).to eq('REP(i, N) scanf("%s", A[i]);')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:size) { 'N' }
      let(:item) { :char }
      let(:names) { 'A' }
      it 'generates read script' do
        expect(subject).to eq('scanf("%s", A);')
      end
    end

    context 'for vertical array of numbers' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates read script' do
        expect(subject).to eq('REP(i, N) scanf("%d%d", A + i, B + i);')
      end
    end

    context 'for vertical array of strings' do
      let(:container) { :varray }
      let(:size) { 'N' }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates read script' do
        expect(subject).to eq('REP(i, N) scanf("%s%s", A[i], B[i]);')
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :number }
      let(:names) { 'A' }
      it 'generates read script' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%d", &A[i][j]);')
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :string }
      let(:names) { 'A' }
      it 'generates read script' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%s", A[i][j]);')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:size) { %w[R C] }
      let(:item) { :char }
      let(:names) { 'A' }
      it 'generates read script' do
        expect(subject).to eq('REP(i, R) scanf("%s", A[i]);')
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(defs, desc) }
    let(:defs) do
      [
        AtCoderFriends::InputDef.new(:single, nil, :number, %w[N M]),
        AtCoderFriends::InputDef.new(:varray, 'M', :number, %w[A B C T]),
      ]
    end

    let(:desc) do
      <<~DESC
        1 行目には、村の個数を表した整数 N (2 ≦ N ≦ 10^4) と、
        道の本数を表した整数 M (1 ≦ M ≦ 10^4) が空白区切りで与えられる。
        続く M 行には、道の情報が与えられる。
        このうちの i 行目には 4 つの整数
        A_i (0 ≦ A_i ≦ N-1), B_i (0 ≦ B_i ≦ N-1),
        C_i (1 ≤ C_i ≤ 10^6), T_i (1 leq T_i leq 10^6)
        が空白区切りで書かれており、これは 村 A_i と村 B_i を繋ぐ道があり、
        この道を修理するために費用が C_i、時間が T_i かかることを表している。
      DESC
    end

    it 'generates c++ source' do
      expect(subject).to eq(
        <<~SRC
          #include <cstdio>

          using namespace std;

          #define REP(i,n)   for(int i=0; i<(int)(n); i++)
          #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

          const int N_MAX = 10000;
          const int M_MAX = 10000;
          const int C_I_MAX = 1000000;
          const int T_I_MAX = 1000000;

          int N, M;
          int A[M_MAX];
          int B[M_MAX];
          int C[M_MAX];
          int T[M_MAX];

          void solve() {
            int ans = 0;
            printf("%d\\n", ans);
          }

          void input() {
            scanf("%d%d", &N, &M);
            REP(i, M) scanf("%d%d%d%d", A + i, B + i, C + i, T + i);
          }

          int main() {
            input();
            solve();
            return 0;
          }
        SRC
      )
    end
  end
end
