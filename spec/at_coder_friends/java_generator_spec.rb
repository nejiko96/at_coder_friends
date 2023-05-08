# frozen_string_literal: true

ACF_HOME = File.realpath(File.join(__dir__, '..', '..'))
TMPL_DIR = File.join(ACF_HOME, 'templates')
TEMPLATE = File.join(TMPL_DIR, 'java_sample.java.erb')
FRAGMENTS = File.join(TMPL_DIR, 'java_sample_fragments.yml')

RSpec.describe AtCoderFriends::Generator::AnyBuiltin do
  subject(:generator) { described_class.new(cfg) }
  let(:cfg) do
    {
      'file_ext' => 'java',
      'template' => TEMPLATE,
      'fragments' => FRAGMENTS
    }
  end

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:java)
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
          'public static final int N_MAX = 10_000;',
          'public static final int M_MAX = (int)1e9;',
          'public static final int C_I_MAX = 2*(int)1e5;',
          'public static final int MOD = 998_244_353;'
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
        expect(subject).to eq(
          <<~SRC
            int A = sc.nextInt();
          SRC
        )
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:cols) { %i[number] * 2 }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int A = sc.nextInt();
            int B = sc.nextInt();
          SRC
        )
      end
    end

    context 'for a plain decimal' do
      let(:container) { :single }
      let(:cols) { %i[decimal] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double A = sc.nextDouble();
          SRC
        )
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:cols) { %i[string] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            String A = sc.next();
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
            int A = sc.nextInt();
            double B = sc.nextDouble();
            String C = sc.next();
          SRC
        )
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:item) { :number }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[] A = new int[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.nextInt();
            }
          SRC
        )
      end
    end

    context 'for a horizontal array of decimals' do
      let(:container) { :harray }
      let(:cols) { %i[decimal] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double[] A = new double[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.nextDouble();
            }
          SRC
        )
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:cols) { %i[string] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            String[] A = new String[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.next();
            }
          SRC
        )
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            char[] A = sc.next().toCharArray();
          SRC
        )
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
            int[] A = new int[N];
            int[] B = new int[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.nextInt();
                B[i] = sc.nextInt();
            }
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
            double[] A = new double[N];
            double[] B = new double[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.nextDouble();
                B[i] = sc.nextDouble();
            }
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
            String[] A = new String[N];
            String[] B = new String[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.next();
                B[i] = sc.next();
            }
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
            int[] A = new int[N];
            double[] B = new double[N];
            String[] C = new String[N];
            for (int i = 0; i < N; i++) {
                A[i] = sc.nextInt();
                B[i] = sc.nextDouble();
                C[i] = sc.next();
            }
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
            int[][] A = new int[R][C];
            for (int i = 0; i < R; i++) {
                for (int j = 0; j < C; j++) {
                    A[i][j] = sc.nextInt();
                }
            }
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
            double[][] A = new double[R][C];
            for (int i = 0; i < R; i++) {
                for (int j = 0; j < C; j++) {
                    A[i][j] = sc.nextDouble();
                }
            }
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
            String[][] A = new String[R][C];
            for (int i = 0; i < R; i++) {
                for (int j = 0; j < C; j++) {
                    A[i][j] = sc.next();
                }
            }
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
            char[][] A = new char[R][];
            for (int i = 0; i < R; i++) {
                A[i] = sc.next().toCharArray();
            }
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
            int[] K = new int[N];
            int[][] A = new int[N][];
            for (int i = 0; i < N; i++) {
                K[i] = sc.nextInt();
                A[i] = new int[K[i]];
                for (int j = 0; j < K[i]; j++) {
                    A[i][j] = sc.nextInt();
                }
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
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[] K = new int[Q];
            char[][] p = new char[Q][];
            for (int i = 0; i < Q; i++) {
                K[i] = sc.nextInt();
                p[i] = sc.next().toCharArray();
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
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[][] city = new int[M][2];
            int[] cost = new int[M];
            for (int i = 0; i < M; i++) {
                for (int j = 0; j < 2; j++) {
                    city[i][j] = sc.nextInt();
                }
                cost[i] = sc.nextInt();
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
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[][] idol = new int[1][C_1];
            int[][] p = new int[1][C_1];
            for (int i = 0; i < 1; i++) {
                for (int j = 0; j < C_1; j++) {
                    idol[i][j] = sc.nextInt();
                    p[i][j] = sc.nextInt();
                }
            }
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
            int[][] A = new int[N][M];
            double[][] B = new double[N][M];
            String[][] C = new String[N][M];
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < M; j++) {
                    A[i][j] = sc.nextInt();
                    B[i][j] = sc.nextDouble();
                    C[i][j] = sc.next();
                }
            }
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
            int[][] x = new int[Q][2];
            int[][] y = new int[Q][2];
            for (int i = 0; i < Q; i++) {
                for (int j = 0; j < 2; j++) {
                    x[i][j] = sc.nextInt();
                    y[i][j] = sc.nextInt();
                }
            }
          SRC
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

            import java.util.*;

            public class Main {

                public static final int N_MAX = 100000;
                public static final int M_MAX = (int)1e9;
                public static final int C_I_MAX = 2*(int)1e5;
                public static final int T_I_MAX = 1_000_000;
                public static final int MOD = (int)1e9+7;

                public static void main(String[] args) {
                    Scanner sc = new Scanner(System.in);
                    int N = sc.nextInt();
                    int M = sc.nextInt();
                    int[] A = new int[M];
                    int[] B = new int[M];
                    int[] C = new int[M];
                    int[] T = new int[M];
                    for (int i = 0; i < M; i++) {
                        A[i] = sc.nextInt();
                        B[i] = sc.nextInt();
                        C[i] = sc.nextInt();
                        T[i] = sc.nextInt();
                    }
                    int[] K = new int[N];
                    int[][] A = new int[N][];
                    for (int i = 0; i < N; i++) {
                        K[i] = sc.nextInt();
                        A[i] = new int[K[i]];
                        for (int j = 0; j < K[i]; j++) {
                            A[i][j] = sc.nextInt();
                        }
                    }

                    int ans = 0;
                    System.out.println(ans);
                }
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

            import java.util.*;

            public class Main {

                public static final int N_MAX = 9;

                public static void main(String[] args) {
                    Scanner sc = new Scanner(System.in);
                    int N = sc.nextInt();

                    boolean cond = false;
                    System.out.println(cond ? "YES" : "NO");
                }
            }
          SRC
        )
      end
    end
  end
end
