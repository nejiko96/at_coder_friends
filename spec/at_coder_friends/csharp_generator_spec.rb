# frozen_string_literal: true

ACF_HOME = File.realpath(File.join(__dir__, '..', '..'))
TMPL_DIR = File.join(ACF_HOME, 'templates')
CS_TEMPLATE = File.join(TMPL_DIR, 'csharp_sample.cs.erb')
CS_FRAGMENTS = File.join(TMPL_DIR, 'csharp_sample_fragments.yml')

RSpec.describe AtCoderFriends::Generator::AnyBuiltin do
context 'with csharp template specified' do
  subject(:generator) { described_class.new(cfg) }

  let(:cfg) do
    {
      'file_ext' => 'cs',
      'template' => CS_TEMPLATE,
      'fragments' => CS_FRAGMENTS
    }
  end

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:cs)
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
          'const int N_MAX = 10_000;',
          'const int M_MAX = (int)1e9;',
          'const int C_I_MAX = 2*(int)1e5;',
          'const int MOD = 998_244_353;'
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
        delim: delim
      )
    end
    let(:names) { %w[A] }
    let(:size) { [] }
    let(:delim) { '' }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      it 'generates decl' do
        expect(subject).to eq('int A = int.Parse(Console.ReadLine());')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[] AB = Console.ReadLine().Split().Select(int.Parse).ToArray();
            int A = AB[0];
            int B = AB[1];
          SRC
        )
      end
    end

    context 'for a plain decimal' do
      let(:container) { :single }
      let(:item) { :decimal }
      it 'generates decl' do
        expect(subject).to eq('double A = double.Parse(Console.ReadLine());')
      end
    end

    context 'for plain decimals' do
      let(:container) { :single }
      let(:item) { :decimal }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double[] AB = Console.ReadLine().Split().Select(double.Parse).ToArray();
            double A = AB[0];
            double B = AB[1];
          SRC
        )
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      it 'generates decl' do
        expect(subject).to eq('string A = Console.ReadLine();')
      end
    end

    context 'for plain strings' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            string[] AB = Console.ReadLine().Split();
            string A = AB[0];
            string B = AB[1];
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
          'int[] A = Console.ReadLine().Split().Select(int.Parse).ToArray();'
        )
      end
    end

    context 'for a horizontal array of decimals' do
      let(:container) { :harray }
      let(:item) { :decimal }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          'double[] A = Console.ReadLine().Split().Select(double.Parse).ToArray();'
        )
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:item) { :string }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          'string[] A = Console.ReadLine().Split();'
        )
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          'string A = Console.ReadLine();'
        )
      end
    end

    context 'for single vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          'int[] A = Enumerable.Range(0, N).Select(_ => int.Parse(Console.ReadLine())).ToArray();'
        )
      end
    end

    context 'for single vertical array of decimals' do
      let(:container) { :varray }
      let(:item) { :decimal }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          'double[] A = Enumerable.Range(0, N).Select(_ => double.Parse(Console.ReadLine())).ToArray();'
        )
      end
    end

    context 'for single vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          'string[] A = Enumerable.Range(0, N).Select(_ => Console.ReadLine()).ToArray();'
        )
      end
    end

    context 'for multiple vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[] A = new int[N];
            int[] B = new int[N];
            for (int i = 0; i < N; i++)
            {
                int[] AB = Console.ReadLine().Split().Select(int.Parse).ToArray();
                A[i] = AB[0];
                B[i] = AB[1];
            }
          SRC
        )
      end
    end

    context 'for multiple vertical array of decimals' do
      let(:container) { :varray }
      let(:item) { :decimal }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double[] A = new double[N];
            double[] B = new double[N];
            for (int i = 0; i < N; i++)
            {
                double[] AB = Console.ReadLine().Split().Select(double.Parse).ToArray();
                A[i] = AB[0];
                B[i] = AB[1];
            }
          SRC
        )
      end
    end

    context 'for multple vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            string[] A = new string[N];
            string[] B = new string[N];
            for (int i = 0; i < N; i++)
            {
                string[] AB = Console.ReadLine().Split();
                A[i] = AB[0];
                B[i] = AB[1];
            }
          SRC
        )
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:item) { :number }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[][] A = Enumerable.Range(0, R).Select(_ =>
                Console.ReadLine().Split().Select(int.Parse).ToArray()
            ).ToArray();
          SRC
        )
      end
    end

    context 'for a matrix of decimals' do
      let(:container) { :matrix }
      let(:item) { :decimal }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double[][] A = Enumerable.Range(0, R).Select(_ =>
                Console.ReadLine().Split().Select(double.Parse).ToArray()
            ).ToArray();
          SRC
        )
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:item) { :string }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            string[][] A = Enumerable.Range(0, R).Select(_ =>
                Console.ReadLine().Split()
            ).ToArray();
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
            string[] A = Enumerable.Range(0, R).Select(_ =>
                Console.ReadLine()
            ).ToArray();
          SRC
        )
      end
    end

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:item) { :number }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[] K = new int[N];
            int[][] A = new int[N][];
            for (int i = 0; i < N; i++)
            {
                int[] KA = Console.ReadLine().Split().Select(int.Parse).ToArray();
                K[i] = KA[0];
                A[i] = KA.Skip(1).ToArray();
            }
          SRC
        )
      end
    end

    context 'for a vertical array and a matrix of decimals' do
      let(:container) { :varray_matrix }
      let(:item) { :decimal }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            double[] K = new double[N];
            double[][] A = new double[N][];
            for (int i = 0; i < N; i++)
            {
                double[] KA = Console.ReadLine().Split().Select(double.Parse).ToArray();
                K[i] = KA[0];
                A[i] = KA.Skip(1).ToArray();
            }
          SRC
        )
      end
    end

    context 'for a vertical array and a matrix of characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            string[] K = new string[Q];
            string[] p = new string[Q];
            for (int i = 0; i < Q; i++)
            {
                string[] Kp = Console.ReadLine().Split();
                K[i] = Kp[0];
                p[i] = Kp.Last();
            }
          SRC
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:item) { :number }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[][] city = new int[M][];
            int[] cost = new int[M];
            for (int i = 0; i < M; i++)
            {
                int[] citycost = Console.ReadLine().Split().Select(int.Parse).ToArray();
                city[i] = citycost.Take(citycost.Count - 1).ToArray();
                cost[i] = citycost[citycost.Count - 1];
            }
          SRC
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:item) { :number }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[][] idol = new int[1][C_1];
            int[][] p = new int[1][C_1];
            for (int i = 0; i < 1; i++)
            {
                for (int j = 0; j < C_1; j++)
                {
                    int[] idolp = Console.ReadLine().Split().Select(int.Parse).ToArray();
                    idol[i][j] = idolp[0];
                    p[i][j] = idolp[1];
                }
            }
          SRC
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:item) { :number }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[][] x = new int[Q][2];
            int[][] y = new int[Q][2];
            for (int i = 0; i < Q; i++)
            {
                int[] xy = Console.ReadLine().Split().Select(int.Parse).ToArray();
                for (int j = 0; j < 2; j++)
                {
                    x[i][j] = xy[j * 2 + 0];
                    y[i][j] = xy[j * 2 + 1];
                }
            }
          SRC
        )
      end
    end

    context 'for format with delimiters' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:names) { %w[S E] }
      let(:size) { %w[N] }
      let(:delim) { '-' }
      it 'generates decl' do
        expect(subject).to eq(
          <<~SRC
            int[] S = new int[N];
            int[] E = new int[N];
            for (int i = 0; i < N; i++)
            {
                int[] SE = Console.ReadLine().Replace('-', ' ').Split().Select(int.Parse).ToArray();
                S[i] = SE[0];
                E[i] = SE[1];
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
            container: :single, names: %w[N]
          ),
          AtCoderFriends::Problem::InputFormat.new(
            container: :varray, names: %w[x y], size: %w[N]
          ),
          AtCoderFriends::Problem::InputFormat.new(
            container: :single, item: :string, names: %w[Q]
          ),
          AtCoderFriends::Problem::InputFormat.new(
            container: :harray, item: :string, names: %w[a], size: %w[Q]
          ),
          AtCoderFriends::Problem::InputFormat.new(
            container: :varray_matrix,
            item: :number,
            names: %w[K A],
            size: %w[N K_N]
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '100000'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '10^9+7')
        ]
      end
      let(:interactive) { false }
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~SRC
            // https://atcoder.jp/contests/practice/tasks/practice_1

            using System;
            using System.Collections;
            using System.Collections.Generic;
            using System.Linq;
            using System.Text;

            class Program
            {
                static void Main(string[] args)
                {
                    const int N_MAX = 100000;
                    const int MOD = (int)1e9+7;

                    int N = int.Parse(Console.ReadLine());
                    int[] x = new int[N];
                    int[] y = new int[N];
                    for (int i = 0; i < N; i++)
                    {
                        int[] xy = Console.ReadLine().Split().Select(int.Parse).ToArray();
                        x[i] = xy[0];
                        y[i] = xy[1];
                    }
                    string Q = Console.ReadLine();
                    string[] a = Console.ReadLine().Split();
                    int[] K = new int[N];
                    int[][] A = new int[N][];
                    for (int i = 0; i < N; i++)
                    {
                        int[] KA = Console.ReadLine().Split().Select(int.Parse).ToArray();
                        K[i] = KA[0];
                        A[i] = KA.Skip(1).ToArray();
                    }

                    int ans = 0;
                    Console.WriteLine(ans);
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
            container: :single, names: %w[N]
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

            using System;
            using System.Collections;
            using System.Collections.Generic;
            using System.Linq;
            using System.Text;

            class Program
            {
                static void Main(string[] args)
                {
                    const int N_MAX = 9;

                    int N = int.Parse(Console.ReadLine());

                    bool cond = false;
                    Console.WriteLine(cond ? "YES" : "NO");
                }
            }
          SRC
        )
      end
    end
  end
end
end
