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
    let(:agent) { AtCoderFriends::Scraping::Agent.new(ctx) }
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

    context 'for case #1' do
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

    context 'for case #2' do
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

    context 'for case #3' do
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

    context 'for case #4' do
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

    context 'for case #5' do
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

    context 'for case #6' do
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

    context 'for case #7' do
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

    context 'for case #8' do
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

    context 'for case #9' do
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

    context 'for case #10' do
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

    context 'for case #11' do
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

    context 'for case #12' do
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
    context 'for case #13' do
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
  end
end
