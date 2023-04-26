# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::CBuiltin do
  subject(:generator) { described_class.new }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:c)
    end
  end

  describe '#gen_consts' do
    subject { generator.gen_consts(constants) }
    let(:constants) do
      [
        AtCoderFriends::Problem::Constant.new('N', :max, '10,000'),
        AtCoderFriends::Problem::Constant.new('M', :max, '10^9'),
        AtCoderFriends::Problem::Constant.new('C_i', :max, '2*10^5'),
        AtCoderFriends::Problem::Constant.new(nil, :mod, '998,244,353')
      ]
    end

    it 'generates constant decls' do
      expect(subject).to match(
        [
          '#define N_MAX 10000',
          '#define M_MAX 1e9',
          '#define C_I_MAX 2*1e5',
          '#define MOD 998244353'
        ]
      )
    end
  end

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(
        container: container,
        item: item,
        names: names,
        size: size,
        delim: '',
        cols: cols
      )
    end
    let(:item) { nil }
    let(:size) { [] }
    let(:names) { %w[A] }
    let(:cols) { [] }

    context 'for a plain number' do
      let(:container) { :single }
      let(:cols) { %i[number] }
      it 'generates decl' do
        expect(subject).to eq('int A;')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('int A, B;')
      end
    end

    context 'for a plain decimal' do
      let(:container) { :single }
      let(:cols) { %i[decimal] }
      it 'generates decl' do
        expect(subject).to eq('double A;')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:cols) { %i[string] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            char A[A_MAX + 1];
          SRC
        )
      end
    end

    context 'for plain variables of mixed types' do
      let(:container) { :single }
      let(:cols) { %i[number decimal string] }
      let(:names) { %w[A B C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A;
            double B;
            char C[C_MAX + 1];
          SRC
        )
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:cols) { %i[number] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('int A[N_MAX];')
      end
    end

    context 'for a horizontal array of numbers with size specified' do
      let(:container) { :harray }
      let(:cols) { %i[number] }
      let(:size) { %w[10] }
      it 'generates decl' do
        expect(subject).to eq('int A[10];')
      end
    end

    context 'for a horizontal array of decimals' do
      let(:container) { :harray }
      let(:cols) { %i[decimal] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('double A[N_MAX];')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:cols) { %i[string] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('char A[N_MAX][A_MAX + 1];')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('char A[N_MAX + 1];')
      end
    end

    context 'for vertical array of numbers' do
      let(:container) { :varray }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A[N_MAX];
            int B[N_MAX];
          SRC
        )
      end
    end

    context 'for vertical array of numbers with size specified' do
      let(:container) { :varray }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[A B] }
      let(:size) { %w[10] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A[10];
            int B[10];
          SRC
        )
      end
    end

    context 'for vertical array of decimals' do
      let(:container) { :varray }
      let(:cols) { %i[decimal] * 2 }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double A[N_MAX];
            double B[N_MAX];
          SRC
        )
      end
    end

    context 'for vertical array of strings' do
      let(:container) { :varray }
      let(:cols) { %i[string] * 2 }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            char A[N_MAX][A_MAX + 1];
            char B[N_MAX][B_MAX + 1];
          SRC
        )
      end
    end

    context 'for vertical array of mixed types' do
      let(:container) { :varray }
      let(:cols) { %i[number decimal string] }
      let(:names) { %w[A B C] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A[N_MAX];
            double B[N_MAX];
            char C[N_MAX][C_MAX + 1];
          SRC
        )
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:cols) { %i[number] }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A[R_MAX][C_MAX];
          SRC
        )
      end
    end

    context 'for a matrix of numbers with size specified' do
      let(:container) { :matrix }
      let(:cols) { %i[number] }
      let(:size) { %w[8 8] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A[8][8];
          SRC
        )
      end
    end

    context 'for a matrix of decimals' do
      let(:container) { :matrix }
      let(:cols) { %i[decimal] }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double A[R_MAX][C_MAX];
          SRC
        )
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:cols) { %i[string] }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            char A[R_MAX][C_MAX][A_MAX + 1];
          SRC
        )
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:item) { :char }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            char A[R_MAX][C_MAX + 1];
          SRC
        )
      end
    end

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int K[N_MAX];
            int A[N_MAX][K_N_MAX];
          SRC
        )
      end
    end

    context 'for a vertical array and a matrix of characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:cols) { %i[number string] }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int K[Q_MAX];
            char p[Q_MAX][26 + 1];
          SRC
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int city[M_MAX][2];
            int cost[M_MAX];
          SRC
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int idol[1][C_1_MAX];
            int p[1][C_1_MAX];
          SRC
        )
      end
    end

    context 'for vertical expanded matrices of mixed types' do
      let(:container) { :vmatrix }
      let(:cols) { %i[number decimal string] }
      let(:names) { %w[A B C] }
      let(:size) { %w[N M] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A[N_MAX][M_MAX];
            double B[N_MAX][M_MAX];
            char C[N_MAX][M_MAX][C_MAX + 1];
          SRC
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int x[Q_MAX][2];
            int y[Q_MAX][2];
          SRC
        )
      end
    end
  end

  describe '#gen_input' do
    subject { generator.gen_input(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(
        container: container,
        item: item,
        names: names,
        size: size,
        delim: '',
        cols: cols
      )
    end
    let(:item) { nil }
    let(:size) { [] }
    let(:names) { %w[A] }
    let(:cols) { [] }

    context 'for a plain number' do
      let(:container) { :single }
      let(:cols) { %i[number] }
      it 'generates input code' do
        expect(subject).to eq('scanf("%d", &A);')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[A B] }
      it 'generates input code' do
        expect(subject).to eq('scanf("%d%d", &A, &B);')
      end
    end

    context 'for a plain decimal' do
      let(:container) { :single }
      let(:cols) { %i[decimal] }
      it 'generates input code' do
        expect(subject).to eq('scanf("%lf", &A);')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:cols) { %i[string] }
      it 'generates input code' do
        expect(subject).to eq('scanf("%s", A);')
      end
    end

    context 'for plain variables of mixed types' do
      let(:container) { :single }
      let(:cols) { %i[number decimal string] }
      let(:names) { %w[A B C] }
      it 'generates input code' do
        expect(subject).to eq('scanf("%d%lf%s", &A, &B, C);')
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:cols) { %i[number] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%d", A + i);')
      end
    end

    context 'for a horizontal array of decimals' do
      let(:container) { :harray }
      let(:cols) { %i[decimal] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%lf", A + i);')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:cols) { %i[string] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%s", A[i]);')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('scanf("%s", A);')
      end
    end

    context 'for vertical array of numbers' do
      let(:container) { :varray }
      let(:cols) { %i[number] }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%d%d", A + i, B + i);')
      end
    end

    context 'for vertical array of decimals' do
      let(:container) { :varray }
      let(:cols) { %i[decimal] * 2 }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%lf%lf", A + i, B + i);')
      end
    end

    context 'for vertical array of strings' do
      let(:container) { :varray }
      let(:cols) { %i[string] * 2 }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%s%s", A[i], B[i]);')
      end
    end

    context 'for vertical array of mixed types' do
      let(:container) { :varray }
      let(:cols) { %i[number decimal string] }
      let(:names) { %w[A B C] }
      let(:size) { %w[N] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, N) scanf("%d%lf%s", A + i, B + i, C[i]);')
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:cols) { %i[number] }
      let(:size) { %w[R C] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%d", &A[i][j]);')
      end
    end

    context 'for a matrix of decimals' do
      let(:container) { :matrix }
      let(:cols) { %i[decimal] }
      let(:size) { %w[R C] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%lf", &A[i][j]);')
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:cols) { %i[string] }
      let(:size) { %w[R C] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%s", A[i][j]);')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:item) { :char }
      let(:size) { %w[R C] }
      it 'generates input code' do
        expect(subject).to eq('REP(i, R) scanf("%s", A[i]);')
      end
    end

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates input code' do
        expect(subject).to eq(
          <<~SRC
            REP(i, N) {
              scanf("%d", K + i);
              REP(j, K[i]) scanf("%d", &A[i][j]);
            }
          SRC
        )
      end
    end

    context 'for a vertical array and a matrix of characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:cols) { %i[number string] }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates input code' do
        expect(subject).to match(
          <<~SRC
            REP(i, Q) {
              scanf("%d", K + i);
              scanf("%s", p[i]);
            }
          SRC
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates input code' do
        expect(subject).to match(
          <<~SRC
            REP(i, M) {
              REP(j, 2) scanf("%d", &city[i][j]);
              scanf("%d", cost + i);
            }
          SRC
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates input code' do
        expect(subject).to eq(
          'REP(i, 1) REP(j, C_1) scanf("%d%d", &idol[i][j], &p[i][j]);'
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:cols) { %i[number] }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates input code' do
        expect(subject).to eq(
          'REP(i, Q) REP(j, 2) scanf("%d%d", &x[i][j], &y[i][j]);'
        )
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(pbm) }
    let(:pbm) do
      AtCoderFriends::Problem.new('A') do |pbm|
        pbm.formats_src = formats
        pbm.constants = constants
        pbm.options.interactive = interactive
        pbm.options.binary_values = binary_values
      end
    end

    context 'for a general problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_1'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            container: :single,
            names: %w[N M],
            cols: %i[number] * 2
          ),
          AtCoderFriends::Problem::InputFormat.new(
            container: :varray,
            names: %w[A B C T],
            size: %w[M],
            cols: %i[number] * 4
          ),
          AtCoderFriends::Problem::InputFormat.new(
            container: :varray_matrix,
            names: %w[K A],
            size: %w[N K_N],
            cols: %i[number] * 2
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '100000'),
          AtCoderFriends::Problem::Constant.new('M', :max, '10^9'),
          AtCoderFriends::Problem::Constant.new('C_i', :max, '2*10^5'),
          AtCoderFriends::Problem::Constant.new('T_i', :max, '1,000,000'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '10^9+7')
        ]
      end
      let(:interactive) { false }
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~SRC
            // https://atcoder.jp/contests/practice/tasks/practice_1

            #include <stdio.h>

            #define REP(i,n)   for(int i=0; i<(int)(n); i++)
            #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

            #define N_MAX 100000
            #define M_MAX 1e9
            #define C_I_MAX 2*1e5
            #define T_I_MAX 1000000
            #define MOD 1e9+7

            int N, M;
            int A[M_MAX];
            int B[M_MAX];
            int C[M_MAX];
            int T[M_MAX];
            int K[N_MAX];
            int A[N_MAX][K_N_MAX];

            void solve() {
              int ans = 0;
              printf("%d\\n", ans);
            }

            void input() {
              scanf("%d%d", &N, &M);
              REP(i, M) scanf("%d%d%d%d", A + i, B + i, C + i, T + i);
              REP(i, N) {
                scanf("%d", K + i);
                REP(j, K[i]) scanf("%d", &A[i][j]);
              }
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

    context 'for a binary problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/abc006/tasks/abc006_1'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            container: :single,
            names: %w[N],
            cols: %i[number]
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '9')
        ]
      end
      let(:interactive) { false }
      let(:binary_values) { %w[YES NO] }

      it 'generates source' do
        expect(subject).to eq(
          <<~SRC
            // https://atcoder.jp/contests/abc006/tasks/abc006_1

            #include <stdio.h>

            #define REP(i,n)   for(int i=0; i<(int)(n); i++)
            #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

            #define N_MAX 9

            int N;

            void solve() {
              int cond = 0;
              puts(cond ? "YES" : "NO");
            }

            void input() {
              scanf("%d", &N);
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
end
