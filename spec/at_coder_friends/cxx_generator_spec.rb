# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::CxxBuiltin do
  subject(:generator) { described_class.new }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:cxx)
    end
  end

  describe '#gen_const' do
    subject { constants.map { |c| generator.gen_const(c) } }
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

    context 'for an interactive problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_2'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(
            container: :single,
            names: %w[N Q],
            cols: %i[number] * 2
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
