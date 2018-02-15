# frozen_string_literal: true

RSpec.describe AtCoderFriends::FormatParser do
  subject(:parser) do
    described_class.new
  end

  let(:smps) do
    [
      AtCoderFriends::DataSample.new('1', :in, '0'),
      AtCoderFriends::DataSample.new('1', :exp, 'YES'),
      AtCoderFriends::DataSample.new('2', :in, '#'),
      AtCoderFriends::DataSample.new('3', :in, smp)
    ]
  end
  let(:fmt) { '' }
  let(:smp) { '' }

  describe '#parse' do
    subject { parser.parse(fmt, smps) }
    context 'for case #1' do
      let(:fmt) do
        <<~FMT
          N M P Q R
          x_1 y_1 z_1
          x_2 y_2 z_2
          :
          x_R y_R z_R
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
          type: :single, fmt: :number, vars: %w[N M P Q R]
        )
        expect(defs[1]).to have_attributes(
          type: :varray, size: 'R', fmt: :number, vars: %w[x y z]
        )
      end
    end

    context 'for case #2' do
      let(:fmt) { 'Deg Dis' }
      let(:smp) { '113 201' }
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          type: :single, fmt: :number, vars: %w[Deg Dis]
        )
      end
    end

    context 'for case #3' do
      let(:fmt) do
        <<~FMT
          N
          D11 D12 ... D1N
          D21 D22 ... D2N
          ...
          DN1 DN2 ... DNN
          Q
          P1
          P2
          ...
          PQ
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
          type: :single, fmt: :number, vars: %w[N]
        )
        expect(defs[1]).to have_attributes(
          type: :matrix, size: %w[N N], fmt: :number, vars: 'D'
        )
        expect(defs[2]).to have_attributes(
          type: :single, fmt: :number, vars: %w[Q]
        )
        expect(defs[3]).to have_attributes(
          type: :varray, size: 'Q', fmt: :number, vars: %w[P]
        )
      end
    end

    context 'for case #4' do
      let(:fmt) { 'x_a y_a x_b y_b x_c y_c' }
      let(:smp) { '298 520 903 520 4 663' }
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          type: :single, fmt: :number, vars: %w[xa ya xb yb xc yc]
        )
      end
    end

    context 'for case #5' do
      let(:fmt) do
        <<~FMT
          N K
          R_1 R_2 ... R_N
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
          type: :single, fmt: :number, vars: %w[N K]
        )
        expect(defs[1]).to have_attributes(
          type: :harray, size: 'N', fmt: :number, vars: 'R'
        )
      end
    end

    context 'for case #6' do
      let(:fmt) do
        <<~FMT
          R C K
          s_1
          s_2
          :
          s_R
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
          type: :single, fmt: :number, vars: %w[R C K]
        )
        expect(defs[1]).to have_attributes(
          type: :varray, size: 'R', fmt: :string, vars: %w[s]
        )
      end
    end

    context 'for case #7' do
      let(:fmt) { 'X' }
      let(:smp) { 'atcoder' }
      it 'can parse format' do
        defs = subject
        expect(defs.size).to eq(1)
        expect(defs[0]).to have_attributes(
          type: :single, fmt: :string, vars: %w[X]
        )
      end
    end

    context 'for case #8' do
      let(:fmt) do
        <<~FMT
          s_1 e_1
          s_2 e_2
          s_3 e_3
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
          type: :varray, size: '3', fmt: :number, vars: %w[s e]
        )
      end
    end

    context 'for case #9' do
      let(:fmt) do
        <<~FMT
          c_{0,0} c_{0,1} c_{0,2} c_{0,3}
          c_{1,0} c_{1,1} c_{1,2} c_{1,3}
          c_{2,0} c_{2,1} c_{2,2} c_{2,3}
          c_{3,0} c_{3,1} c_{3,2} c_{3,3}
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
          type: :matrix, size: %w[3 3], fmt: :string, vars: 'c'
        )
      end
    end

    context 'for case #10' do
      let(:fmt) do
        <<~FMT
          N
          x_1\ y_1
          x_2\ y_2
          ：
          x_{N-1}\ y_{N-1}
          Q
          a_1\ b_1
          a_2\ b_2
          ：
          a_{Q}\ b_{Q}
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
          type: :single, fmt: :number, vars: %w[N]
        )
        expect(defs[1]).to have_attributes(
          type: :varray, size: 'N', fmt: :number, vars: %w[x y]
        )
        expect(defs[2]).to have_attributes(
          type: :single, fmt: :number, vars: %w[Q]
        )
        expect(defs[3]).to have_attributes(
          type: :varray, size: 'Q', fmt: :number, vars: %w[a b]
        )
      end
    end

    context 'for case #11' do
      let(:fmt) do
        <<~FMT
          H W T
          s_{1, 1}s_{1, 2} .. s_{1, W}
          s_{2, 1}s_{2, 2} .. s_{2, W}
          :
          s_{H, 1}s_{H, 2} .. s_{H, W}
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
          type: :single, fmt: :number, vars: %w[H W T]
        )
        expect(defs[1]).to have_attributes(
          type: :matrix, size: %w[H W], fmt: :char, vars: 's'
        )
      end
    end

    context 'for case #12' do
      let(:fmt) do
        <<~FMT
          N
          c_1c_2c_3…c_N
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
          type: :single, fmt: :number, vars: %w[N]
        )
        expect(defs[1]).to have_attributes(
          type: :harray, size: 'N', fmt: :char, vars: 'c'
        )
      end
    end
    context 'for case #13' do
      let(:fmt) do
        <<~FMT
          N
          x_{11}x_{12}...x_{18}x_{19}
          x_{21}x_{22}...x_{28}x_{29}
          :
          x_{N1}x_{N2}...x_{N8}x_{N9}
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
          type: :single, fmt: :number, vars: %w[N]
        )
        expect(defs[1]).to have_attributes(
          type: :matrix, size: %w[N 9], fmt: :char, vars: 'x'
        )
      end
    end
  end
end
