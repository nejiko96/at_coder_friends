# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::InputType do
  subject(:parser) { described_class }

  describe '#parse' do
    subject { parser.parse(defs, smps) }

    let(:smps) do
      [
        AtCoderFriends::Problem::SampleData.new('1', :in, '0'),
        AtCoderFriends::Problem::SampleData.new('1', :exp, 'YES'),
        AtCoderFriends::Problem::SampleData.new('2', :in, '#'),
        AtCoderFriends::Problem::SampleData.new('3', :in, smp)
      ]
    end
    let(:smp) { '' }
    let(:f) { ->(*args) { AtCoderFriends::Problem::InputFormat.new(*args) } }

    context 'for single(number)-varray(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[N M P Q R], []],
          f[:varray, :number, %w[x y z], %w[R]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
      end
    end

    context 'for single(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[Deg Dis], []]
        ]
      end
      let(:smp) { '113 201' }
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
      end
    end

    context 'for single(number)-matrix(number)-single(number)-varray(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[N], []],
          f[:matrix, :number, %w[D], %w[N N]],
          f[:single, :number, %w[Q], []],
          f[:varray, :number, %w[P], %w[Q]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
        expect(defs[2].item).to eq :number
        expect(defs[3].item).to eq :number
      end
    end

    context 'for single(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[x_a y_a x_b y_b x_c y_c], []]
        ]
      end
      let(:smp) { '298 520 903 520 4 663' }
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
      end
    end

    context 'for single(number)-harray(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[N K], []],
          f[:harray, :number, %w[R], %w[N]]
        ]
      end
      let(:smp) do
        <<~SMP
          10 5
          2604 2281 3204 2264 2200 2650 2229 2461 2439 2211
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
      end
    end

    context 'for single(number)-varray(string)' do
      let(:defs) do
        [
          f[:single, :number, %w[R C K], []],
          f[:varray, :number, %w[s], %w[R]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :string
      end
    end

    context 'for single(string)' do
      let(:defs) do
        [
          f[:single, :number, %w[X], []]
        ]
      end
      let(:smp) { 'atcoder' }
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :string
      end
    end

    context 'for varray(number)' do
      let(:defs) do
        [
          f[:varray, :number, %w[s e], %w[3]]
        ]
      end
      let(:smp) do
        <<~SMP
          990 10
          990 10
          990 10
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
      end
    end

    context 'for matrix(string)' do
      let(:defs) do
        [
          f[:matrix, :number, %w[c], %w[3 3]]
        ]
      end
      let(:smp) do
        <<~SMP
          o o x x
          o o x x
          x x o o
          x x o o
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :string
      end
    end

    context 'for single(number)-varray(number)*2' do
      let(:defs) do
        [
          f[:single, :number, %w[N], []],
          f[:varray, :number, %w[x y], %w[N]],
          f[:single, :number, %w[Q], []],
          f[:varray, :number, %w[a b], %w[Q]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
        expect(defs[2].item).to eq :number
        expect(defs[3].item).to eq :number
      end
    end

    context 'for single(number)-matrix(char)' do
      let(:defs) do
        [
          f[:single, :number, %w[H W T], []],
          f[:matrix, :char, %w[s], %w[H W]]
        ]
      end
      let(:smp) do
        <<~SMP
          3 4 7
          S##G
          .##.
          ..#.
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :char
      end
    end

    context 'for single(number)-harray(char)' do
      let(:defs) do
        [
          f[:single, :number, %w[N], []],
          f[:harray, :char, %w[c], %w[N]]
        ]
      end
      let(:smp) do
        <<~SMP
          20
          12341234123412341234
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :char
      end
    end

    context 'for single(number)-matrix(char)' do
      let(:defs) do
        [
          f[:single, :number, %w[N], []],
          f[:matrix, :char, %w[x], %w[N 9]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :char
      end
    end

    context 'for varray_matrix(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[N M], []],
          f[:varray_matrix, :number, %w[K A], %w[N K_N]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
      end
    end

    context 'for varray_matrix(char)' do
      let(:defs) do
        [
          f[:single, :number, %w[N], []],
          f[:varray, :number, %w[S], %w[N]],
          f[:single, :number, %w[Q], []],
          f[:varray_matrix, :char, %w[k p], %w[Q 26]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :string
        expect(defs[2].item).to eq :number
        expect(defs[3].item).to eq :char
      end
    end

    context 'for matrix_varray(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[M], []],
          f[:matrix_varray, :number, %w[city cost], %w[M 2]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[N M], []],
          f[:varray, :number, %w[C cost], %w[1]],
          f[:vmatrix, :number, %w[idol p], %w[1 C_1]]
        ]
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
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :number
        expect(defs[2].item).to eq :number
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:defs) do
        [
          f[:single, :number, %w[N M Q], []],
          f[:matrix, :char, %w[S], %w[N M]],
          f[:hmatrix, :number, %w[x y], %w[Q 2]]
        ]
      end
      let(:smp) do
        <<~SMP
          5 5 6
          11010
          01110
          10101
          11101
          01010
          1 1 5 5
          1 2 4 5
          2 3 3 4
          3 3 3 3
          3 1 3 5
          1 1 3 4
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq :number
        expect(defs[1].item).to eq :char
        expect(defs[2].item).to eq :number
      end
    end

    context 'for unknown format' do
      let(:defs) do
        [
          f[:unknown, '1', nil, nil]
        ]
      end
      let(:smp) do
        <<~SMP
          2
          3
          5
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0].item).to eq '1'
      end
    end
  end
end
