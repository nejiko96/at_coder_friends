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
