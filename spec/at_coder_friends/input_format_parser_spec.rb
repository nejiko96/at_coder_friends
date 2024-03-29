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
    subject { parser.parse(fmt) }
    let(:fmt) { '' }

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
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[R C K], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[s], size: %w[R]
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
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[X], size: []
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
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :matrix, item: :number, names: %w[c], size: %w[3 3]
        )
      end
    end

    context 'for single(number)-varray(number)*2, 1..N-1' do
      let(:fmt) do
        <<~'FMT'
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
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(4)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[x y], size: %w[N-1]
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
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(4)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[S], size: %w[N]
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

    context 'for vertically expanded matrices(number)' do
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

    context 'for horizontally expanded matrices(number)' do
      let(:fmt) do
        <<~FMT
          <pre><var>N</var> <var>M</var> <var>Q</var>
          <var>S_{1,1}</var>..<var>S_{1,M}</var>
          :
          <var>S_{N,1}</var>..<var>S_{N,M}</var>
          <var>x_{1,1}</var> <var>y_{1,1}</var> <var>x_{1,2}</var> <var>y_{1,2}</var>
          :
          <var>x_{Q,1}</var> <var>y_{Q,1}</var> <var>x_{Q,2}</var> <var>y_{Q,2}</var>
          </pre>
        FMT
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(3)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N M Q], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :matrix, item: :char,
          names: %w[S], size: %w[N M]
        )
        expect(defs[2]).to have_attributes(
          container: :hmatrix, item: :number,
          names: %w[x y], size: %w[Q 2]
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
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          container: :unknown, item: '1'
        )
      end
    end

    context 'for format with delimiters' do
      let(:fmt) do
        <<~FMT
          <pre>
          <var>N</var>
          <var>S_1</var>-<var>E_1</var>
          <var>S_2</var>-<var>E_2</var>
          :
          <var>S_N</var>-<var>E_N</var>
          </pre>
        FMT
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(2)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: [],
          delim: ''
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[S E], size: %w[N],
          delim: '-'
        )
      end
    end

    context 'for 0..N-2 lines' do
      let(:fmt) do
        <<~'FMT'
          <pre><var>N</var> <var>Q</var>
          <var>A_0</var> <var>B_0</var>
          <var>A_1</var> <var>B_1</var>
          <var>\vdots</var>
          <var>A_{N-2}</var> <var>B_{N-2}</var>
          <var>X_0</var>
          <var>X_1</var>
          <var>\vdots</var>
          <var>X_{Q-1}</var>
          </pre>
        FMT
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(3)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N Q], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[A B], size: %w[N-1]
        )
        expect(defs[2]).to have_attributes(
          container: :varray, item: :number, names: %w[X], size: %w[Q]
        )
      end
    end

    context 'for 0..0 lines' do
      let(:fmt) do
        <<~FMT
          <pre><var>N</var>
          <var>S_0</var>
          <var>T</var>
          </pre>
        FMT
      end
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(3)
        expect(defs[0]).to have_attributes(
          container: :single, item: :number, names: %w[N], size: []
        )
        expect(defs[1]).to have_attributes(
          container: :varray, item: :number, names: %w[S], size: %w[1]
        )
        expect(defs[2]).to have_attributes(
          container: :single, item: :number, names: %w[T], size: []
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

    context 'when no size specified' do
      let(:str) { '' }

      it 'returns underscore' do
        expect(subject).to match(%w[_ _])
      end
    end
  end
end
