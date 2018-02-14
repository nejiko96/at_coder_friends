# frozen_string_literal: true

RSpec.describe AtCoderFriends::FormatParser do
  subject(:parser) do
    described_class.new
  end

  let(:pbm) do
    pbm = AtCoderFriends::Problem.new('A')
    pbm.fmt = fmt
    pbm.add_smp('1', :in, '0')
    pbm.add_smp('1', :exp, 'YES')
    pbm.add_smp('2', :in, smp)
    pbm
  end
  let(:fmt) { '' }
  let(:smp) { '' }

  describe '#parse' do
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
        defs = parser.parse(pbm)
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
        defs = parser.parse(pbm)
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
        defs = parser.parse(pbm)
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
          type: :varray, size: %w[Q], fmt: :number, vars: %w[P]
        )
      end
    end
  end
end
