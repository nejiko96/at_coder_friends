# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::CxxBuiltin do
  subject(:generator) { described_class.new(cfg) }
  let(:cfg) { nil }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:cxx)
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
          "const int N_MAX = 10'000;",
          'const int M_MAX = 1e9;',
          'const int C_I_MAX = 2*1e5;',
          "const int MOD = 998'244'353;"
        ]
      )
    end
  end

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(container, item, names, size)
    end
    let(:size) { [] }
    let(:names) { %w[A] }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
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

    context 'for a plain decimal' do
      let(:container) { :single }
      let(:item) { :decimal }
      it 'generates decl' do
        expect(subject).to eq('double A;')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      it 'generates decl' do
        expect(subject).to match(['char A[A_MAX + 1];'])
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:item) { :number }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('int A[N_MAX];')
      end
    end

    context 'for a horizontal array of numbers with size specified' do
      let(:container) { :harray }
      let(:item) { :number }
      let(:size) { %w[10] }
      it 'generates decl' do
        expect(subject).to eq('int A[10];')
      end
    end

    context 'for a horizontal array of decimals' do
      let(:container) { :harray }
      let(:item) { :decimal }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('double A[N_MAX];')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:item) { :string }
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
      let(:item) { :number }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'int A[N_MAX];',
            'int B[N_MAX];'
          ]
        )
      end
    end

    context 'for vertical array of numbers with size specified' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:names) { %w[A B] }
      let(:size) { %w[10] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'int A[10];',
            'int B[10];'
          ]
        )
      end
    end

    context 'for vertical array of decimals' do
      let(:container) { :varray }
      let(:item) { :decimal }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'double A[N_MAX];',
            'double B[N_MAX];'
          ]
        )
      end
    end

    context 'for vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'char A[N_MAX][A_MAX + 1];',
            'char B[N_MAX][B_MAX + 1];'
          ]
        )
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:item) { :number }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to match(['int A[R_MAX][C_MAX];'])
      end
    end

    context 'for a matrix of numbers with size specified' do
      let(:container) { :matrix }
      let(:item) { :number }
      let(:size) { %w[8 8] }
      it 'generates decl' do
        expect(subject).to match(['int A[8][8];'])
      end
    end

    context 'for a matrix of decimals' do
      let(:container) { :matrix }
      let(:item) { :decimal }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to match(['double A[R_MAX][C_MAX];'])
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:item) { :string }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to match(['char A[R_MAX][C_MAX][A_MAX + 1];'])
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:item) { :char }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to match(['char A[R_MAX][C_MAX + 1];'])
      end
    end

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:item) { :number }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            ['int K[N_MAX];'],
            ['int A[N_MAX][K_N_MAX];']
          ]
        )
      end
    end

    context 'for a vertical array and a matrix of characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates decl' do
        expect(subject).to match(
          [
            ['int K[Q_MAX];'],
            ['char p[Q_MAX][26 + 1];']
          ]
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:item) { :number }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates decl' do
        expect(subject).to match(
          [
            ['int city[M_MAX][2];'],
            ['int cost[M_MAX];']
          ]
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:item) { :number }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'int idol[1][C_1_MAX];',
            'int p[1][C_1_MAX];'
          ]
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:item) { :number }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'int x[Q_MAX][2];',
            'int y[Q_MAX][2];'
          ]
        )
      end
    end
  end

  describe '#gen_input' do
    subject { generator.gen_input(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(container, item, names, size)
    end
    let(:size) { [] }
    let(:names) { %w[A] }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      it 'generates input script' do
        expect(subject).to eq('scanf("%d", &A);')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates input script' do
        expect(subject).to eq('scanf("%d%d", &A, &B);')
      end
    end

    context 'for a plain decimal' do
      let(:container) { :single }
      let(:item) { :decimal }
      it 'generates input script' do
        expect(subject).to eq('scanf("%lf", &A);')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      it 'generates input script' do
        expect(subject).to eq('scanf("%s", A);')
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:item) { :number }
      let(:size) { %w[N] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, N) scanf("%d", A + i);')
      end
    end

    context 'for a horizontal array of decimals' do
      let(:container) { :harray }
      let(:item) { :decimal }
      let(:size) { %w[N] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, N) scanf("%lf", A + i);')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:item) { :string }
      let(:size) { %w[N] }
      it 'generates read script' do
        expect(subject).to eq('REP(i, N) scanf("%s", A[i]);')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      let(:size) { %w[N] }
      it 'generates read script' do
        expect(subject).to eq('scanf("%s", A);')
      end
    end

    context 'for vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, N) scanf("%d%d", A + i, B + i);')
      end
    end

    context 'for vertical array of decimals' do
      let(:container) { :varray }
      let(:item) { :decimal }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, N) scanf("%lf%lf", A + i, B + i);')
      end
    end

    context 'for vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates read script' do
        expect(subject).to eq('REP(i, N) scanf("%s%s", A[i], B[i]);')
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:item) { :number }
      let(:size) { %w[R C] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%d", &A[i][j]);')
      end
    end

    context 'for a matrix of decimals' do
      let(:container) { :matrix }
      let(:item) { :decimal }
      let(:size) { %w[R C] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%lf", &A[i][j]);')
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:item) { :string }
      let(:size) { %w[R C] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, R) REP(j, C) scanf("%s", A[i][j]);')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:item) { :char }
      let(:size) { %w[R C] }
      it 'generates input script' do
        expect(subject).to eq('REP(i, R) scanf("%s", A[i]);')
      end
    end

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:item) { :number }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates input script' do
        expect(subject).to match(
          [
            'REP(i, N) {',
            '  scanf("%d", K + i);',
            '  REP(j, K[i]) scanf("%d", &A[i][j]);',
            '}'
          ]
        )
      end
    end

    context 'for a vertical array and a matrix of characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates input script' do
        expect(subject).to match(
          [
            'REP(i, Q) {',
            '  scanf("%d", K + i);',
            '  scanf("%s", p[i]);',
            '}'
          ]
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:item) { :number }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates input script' do
        expect(subject).to match(
          [
            'REP(i, M) {',
            '  REP(j, 2) scanf("%d", &city[i][j]);',
            '  scanf("%d", cost + i);',
            '}'
          ]
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:item) { :number }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates input script' do
        expect(subject).to eq(
          'REP(i, 1) REP(j, C_1) scanf("%d%d", &idol[i][j], &p[i][j]);'
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:item) { :number }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates input script' do
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
            :single, :number, %w[N M], []
          ),
          AtCoderFriends::Problem::InputFormat.new(
            :varray, :number, %w[A B C T], %w[M]
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

            #include <cstdio>

            using namespace std;

            #define REP(i,n)   for(int i=0; i<(int)(n); i++)
            #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

            const int N_MAX = 100000;
            const int M_MAX = 1e9;
            const int C_I_MAX = 2*1e5;
            const int T_I_MAX = 1'000'000;
            const int MOD = 1e9+7;

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

    context 'for an interactive problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_2'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            :single, :number, %w[N Q], []
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '26'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '2^32')
        ]
      end
      let(:interactive) { true }
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~SRC
            // https://atcoder.jp/contests/practice/tasks/practice_2

            #include <cstdio>
            #include <vector>
            #include <string>

            using namespace std;

            #define DEBUG
            #define REP(i,n)   for(int i=0; i<(int)(n); i++)
            #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

            //------------------------------------------------------------------------------
            const int BUFSIZE = 1024;
            char req[BUFSIZE];
            char res[BUFSIZE];
            #ifdef DEBUG
            char source[BUFSIZE];
            vector<string> responses;
            #endif

            void query() {
              printf("? %s\\n", req);
              fflush(stdout);
            #ifdef DEBUG
              sprintf(res, "generate response from source");
              responses.push_back(res);
            #else
              scanf("%s", res);
            #endif
            }

            //------------------------------------------------------------------------------
            const int N_MAX = 26;
            const int MOD = 1<<32;

            int N, Q;

            void solve() {
              printf("! %s\\n", ans);
              fflush(stdout);
            #ifdef DEBUG
              printf("query count: %d\\n", responses.size());
              puts("query results:");
              REP(i, responses.size()) {
                puts(responses[i].c_str());
              }
            #endif
            }

            void input() {
              scanf("%d%d", &N, &Q);
            #ifdef DEBUG
              scanf("%s", source);
            #endif
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
            :single, :number, %w[N], []
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

            #include <cstdio>

            using namespace std;

            #define REP(i,n)   for(int i=0; i<(int)(n); i++)
            #define FOR(i,b,e) for(int i=(b); i<=(int)(e); i++)

            const int N_MAX = 9;

            int N;

            void solve() {
              bool cond = false;
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
