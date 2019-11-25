# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::InputFormat do
  subject(:parser) { described_class }

  describe '#process' do
    include_context :atcoder_env
    include_context :atcoder_stub

    subject { parser.process(pbm) }

    let(:pbm) do
      agent
        .fetch_problem('A', File.join('https://atcoder.jp/', url))
        .tap do |pbm|
          AtCoderFriends::Parser::Sections.process(pbm)
          AtCoderFriends::Parser::SampleData.process(pbm)
        end
    end
    let(:agent) { ctx.scraping_agent }
    let(:ctx) { AtCoderFriends::Context.new({}, contest_root) }

    context 'for arc001_1' do
      let(:url) { '/contests/arc001/tasks/arc001_1' }

      it 'parses input format' do
        subject
        expect(pbm.formats.size).to eq(2)
        expect(pbm.formats[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(pbm.formats[1]).to have_attributes(
          container: :harray, item: :char, names: %w[c], size: %w[N]
        )
      end
    end

    context 'for tdpc_contest' do
      let(:url) { '/contests/tdpc/tasks/tdpc_contest' }

      it 'parses input format' do
        subject
        expect(pbm.formats.size).to eq(2)
        expect(pbm.formats[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(pbm.formats[1]).to have_attributes(
          container: :harray, item: :number, names: %w[p], size: %w[N]
        )
      end
    end

    context 'for practice_2' do
      let(:url) { '/contests/practice/tasks/practice_2' }

      it 'parses input format' do
        subject
        expect(pbm.formats.size).to eq(1)
        expect(pbm.formats[0]).to have_attributes(
          container: :single, item: :number, names: %w[N Q], size: []
        )
      end
    end
  end

  describe '#parse' do
    subject { parser.parse(fmt, smps) }

    let(:smps) do
      [
        AtCoderFriends::Problem::SampleData.new('1', :in, '0'),
        AtCoderFriends::Problem::SampleData.new('1', :exp, 'YES'),
        AtCoderFriends::Problem::SampleData.new('2', :in, '#'),
        AtCoderFriends::Problem::SampleData.new('3', :in, smp)
      ]
    end
    let(:fmt) { '' }
    let(:smp) { '' }

    context 'for single(number)-varray(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var> <var>M</var> <var>P</var> <var>Q</var> <var>R</var>
          <var>x_1</var> <var>y_1</var> <var>z_1</var>
          <var>x_2</var> <var>y_2</var> <var>z_2</var>
          :
          <var>x_R</var> <var>y_R</var> <var>z_R</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          4 5 3 2 9
          2 3 5
          3 1 4
          2 2 2
          4 1 9
          3 5 3
          3 3 8
          1 4 5
          1 5 7
          2 4 8
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N M P Q R], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[x y z], size: %w[R]
        )
      end
    end

    context 'for single(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>Deg</var> <var>Dis</var>
          </pre>
        FMT
      end
      let(:smp) { '113 201' }
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[Deg Dis], size: []
        )
      end
    end

    context 'for single(number)-matrix(number)-single(number)-varray(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var>
          <var>D<sub>11</sub> D<sub>12</sub> ... D<sub>1N</sub></var>
          <var>D<sub>21</sub> D<sub>22</sub> ... D<sub>2N</sub></var>
          <var>...</var>
          <var>D<sub>N1</sub> D<sub>N2</sub> ... D<sub>NN</sub></var>
          <var>Q</var>
          <var>P<sub>1</sub></var>
          <var>P<sub>2</sub></var>
          <var>...</var>
          <var>P<sub>Q</sub></var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          3
          3 2 1
          2 2 1
          1 1 1
          3
          1
          4
          9
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(4)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :matrix, item: :number, names: %w[D], size: %w[N N]
        )
        expect(defs[2]).to have_attributes(
          container: :single, item: :number, names: %w[Q], size: []
        )
        expect(defs[3]).to have_attributes(
          container: :varray, item: :number, names: %w[P], size: %w[Q]
        )
      end
    end

    context 'for single(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>x_a</var> <var>y_a</var> <var>x_b</var> <var>y_b</var> <var>x_c</var> <var>y_c</var>
          </pre>
        FMT
      end
      let(:smp) { '298 520 903 520 4 663' }
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number,
          names: %w[x_a y_a x_b y_b x_c y_c], size: []
        )
      end
    end

    context 'for single(number)-harray(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var> <var>K</var>
          <var>R_1</var> <var>R_2</var> ... <var>R_N</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          10 5
          2604 2281 3204 2264 2200 2650 2229 2461 2439 2211
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N K], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :harray, item: :number, names: %w[R], size: %w[N]
        )
      end
    end

    context 'for single(number)-varray(string)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>R</var> <var>C</var> <var>K</var>
          <var>s_1</var>
          <var>s_2</var>
          :
          <var>s_R</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          8 6 3
          oooooo
          oooooo
          oooooo
          oooooo
          oxoooo
          oooooo
          oooooo
          oooooo
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[R C K], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :string, names: %w[s], size: %w[R]
        )
      end
    end

    context 'for single(string)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>X</var>
          </pre>
        FMT
      end
      let(:smp) { 'atcoder' }
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :single, item: :string, names: %w[X], size: []
        )
      end
    end

    context 'for varray(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>s_1</var> <var>e_1</var>
          <var>s_2</var> <var>e_2</var>
          <var>s_3</var> <var>e_3</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          990 10
          990 10
          990 10
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :varray, item: :number, names: %w[s e], size: %w[3]
        )
      end
    end

    context 'for matrix(string)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>c_{0,0}</var> <var>c_{0,1}</var> <var>c_{0,2}</var> <var>c_{0,3}</var>
          <var>c_{1,0}</var> <var>c_{1,1}</var> <var>c_{1,2}</var> <var>c_{1,3}</var>
          <var>c_{2,0}</var> <var>c_{2,1}</var> <var>c_{2,2}</var> <var>c_{2,3}</var>
          <var>c_{3,0}</var> <var>c_{3,1}</var> <var>c_{3,2}</var> <var>c_{3,3}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          o o x x
          o o x x
          x x o o
          x x o o
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :matrix, item: :string, names: %w[c], size: %w[3 3]
        )
      end
    end

    context 'for single(number)-varray(number)*2' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var>
          <var>x_1\ y_1</var>
          <var>x_2\ y_2</var>
          ：
          <var>x_{N-1}\ y_{N-1}</var>
          <var>Q</var>
          <var>a_1\ b_1</var>
          <var>a_2\ b_2</var>
          ：
          <var>a_{Q}\ b_{Q}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          7
          3 1
          2 1
          2 4
          2 5
          3 6
          3 7
          5
          4 5
          1 6
          5 6
          4 7
          5 3
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(4)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[x y], size: %w[N]
        )
        expect(defs[2]).to have_attributes(
          container: :single, item: :number, names: %w[Q], size: []
        )
        expect(defs[3]).to have_attributes(
          container: :varray, item: :number, names: %w[a b], size: %w[Q]
        )
      end
    end

    context 'for single(number)-matrix(char)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>H</var> <var>W</var> <var>T</var>
          <var>s_{1,1}</var><var>s_{1,2}</var> .. <var>s_{1,W}</var>
          <var>s_{2,1}</var><var>s_{2,2}</var> .. <var>s_{2,W}</var>
          :
          <var>s_{H,1}</var><var>s_{H,2}</var> .. <var>s_{H,W}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          3 4 7
          S##G
          .##.
          ..#.
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[H W T], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :matrix, item: :char, names: %w[s], size: %w[H W]
        )
      end
    end

    context 'for single(number)-harray(char)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var>
          <var>c_1c_2c_3…c_N</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          20
          12341234123412341234
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :harray, item: :char, names: %w[c], size: %w[N]
        )
      end
    end

    context 'for single(number)-matrix(char)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var>
          <var>x_{11}</var><var>x_{12}</var><var>...</var><var>x_{18}</var><var>x_{19}</var>
          <var>x_{21}</var><var>x_{22}</var><var>...</var><var>x_{28}</var><var>x_{29}</var>
          :
          <var>x_{N1}</var><var>x_{N2}</var><var>...</var><var>x_{N8}</var><var>x_{N9}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          15
          .........
          .x.......
          .........
          ...x.....
          .........
          .......o.
          .......o.
          .......o.
          .........
          ..x.....o
          ........o
          ........o
          ....x...o
          .x......o
          ........o
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :matrix, item: :char, names: %w[x], size: %w[N 9]
        )
      end
    end

    context 'for varray_matrix(number)' do
      let(:fmt) do
        <<~FMT
          <pre><var>N</var> <var>M</var>
          <var>K_1</var> <var>A_{11}</var> <var>A_{12}</var> <var>...</var> <var>A_{1K_1}</var>
          <var>K_2</var> <var>A_{21}</var> <var>A_{22}</var> <var>...</var> <var>A_{2K_2}</var>
          <var>:</var>
          <var>K_N</var> <var>A_{N1}</var> <var>A_{N2}</var> <var>...</var> <var>A_{NK_N}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          5 5
          4 2 3 4 5
          4 1 3 4 5
          4 1 2 4 5
          4 1 2 3 5
          4 1 2 3 4
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N M], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray_matrix, item: :number,
          names: %w[K A], size: %w[N K_N]
        )
      end
    end

    context 'for varray_matrix(char)' do
      let(:fmt) do
        <<~FMT
          <pre><var>N</var>
          <var>S_1</var>
          :
          <var>S_N</var>
          <var>Q</var>
          <var>k_1</var> <var>p_{1,1}p_{1,2}...p_{1,26}</var>
          :
          <var>k_Q</var> <var>p_{Q,1}p_{Q,2}...p_{Q,26}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          8
          abrakatabra
          abadaba
          abracadabra
          atcoder
          grand
          contest
          ababa
          a
          6
          3 abcdefghijklmnopqrstuvwxyz
          6 qwertyuiopasdfghjklzxcvbnm
          8 poiuytrewqlkjhgfdsamnbvcxz
          2 qazwsxedcrfvtgbyhnujmikolp
          1 plokmijnuhbygvtfcrdxeszwaq
          4 mnbvcxzasdfghjklpoiuytrewq
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(4)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :string, names: %w[S], size: %w[N]
        )
        expect(defs[2]).to have_attributes(
          container: :single, item: :number, names: %w[Q], size: []
        )
        expect(defs[3]).to have_attributes(
          container: :varray_matrix, item: :char, names: %w[k p], size: %w[Q 26]
        )
      end
    end

    context 'for matrix_varray(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>M</var>
          <var>city_{11}</var> <var>city_{12}</var> <var>cost_1</var>
          :
          :
          <var>city_{M1}</var> <var>city_{M2}</var> <var>cost_M</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          12
          1 2 1
          1 3 1
          2 3 1
          3 4 3
          3 5 3
          4 5 3
          5 6 6
          5 7 3
          6 7 9
          5 8 9
          5 9 18
          8 9 27
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[M], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :matrix_varray, item: :number,
          names: %w[city cost], size: %w[M 2]
        )
      end
    end

    context 'for vertically expanded matrix(number)' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var> <var>M</var>
          <var>C_1</var> <var>cost_1</var>
          <var>idol_{1,1}</var> <var>p_{1,1}</var>
          <var>idol_{1,2}</var> <var>p_{1,2}</var>
          :
          <var>idol_{1,C_1}</var> <var>p_{1,C_1}</var>
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          3 3
          2 50
          1 99
          2 1
          3 300
          1 90
          2 9
          3 1
          3 3000
          1 80
          2 15
          3 5
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(3)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N M], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number,
          names: %w[C cost], size: %w[1]
        )
        expect(defs[2]).to have_attributes(
          container: :vmatrix, item: :number,
          names: %w[idol p], size: %w[1 C_1]
        )
      end
    end

    context 'for unknown format' do
      let(:fmt) do
        <<~FMT
          <pre>1
          </pre>
        FMT
      end
      let(:smp) do
        <<~SMP
          2
          3
          5
        SMP
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :unknown, item: '1', names: nil, size: nil
        )
      end
    end
  end

  describe 'split_size' do
    subject { parser.split_size(str) }

    context 'for case #1' do
      let(:str) { '{R,C}' }

      it 'removes surrounding {}' do
        expect(subject).to match(%w[R C])
      end
    end

    context 'for case #2' do
      let(:str) { 'N,N-1' }

      it 'can split by comma' do
        expect(subject).to match(%w[N N-1])
      end
    end

    context 'for case #3' do
      let(:str) { 'M{b_M}' }

      it 'can split by block' do
        expect(subject).to match(%w[M {b_M}])
      end
    end

    context 'for case #4' do
      let(:str) { 'N_TN_T' }

      it 'can split into X and X_X' do
        expect(subject).to match(%w[N_T N_T])
      end
    end

    context 'for case #5' do
      let(:str) { 'NK_N' }

      it 'can split into X and X_X' do
        expect(subject).to match(%w[N K_N])
      end
    end

    context 'for case #6' do
      let(:str) { 'H_W' }

      it 'can split by underscore' do
        expect(subject).to match(%w[H W])
      end
    end

    context 'for case #7' do
      let(:str) { 'ABC' }

      it 'can split 1st char and rest' do
        expect(subject).to match(%w[A BC])
      end
    end

    context 'when no size detected' do
      let(:str) { '' }

      it 'returns underscore' do
        expect(subject).to match(%w[_ _])
      end
    end
  end
end
