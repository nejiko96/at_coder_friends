# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::InputType do
  subject(:parser) { described_class }

  describe '#max_smp' do
    subject { parser.max_smp(smps) }

    let(:smps) do
      [
        AtCoderFriends::Problem::SampleData.new('1', :in, '0'),
        AtCoderFriends::Problem::SampleData.new('1', :exp, 'YES'),
        AtCoderFriends::Problem::SampleData.new('2', :in, '#'),
        AtCoderFriends::Problem::SampleData.new('3', :in, 'NO')
      ]
    end

    it 'finds maximum sample' do
      expect(subject).to eq 'NO'
    end
  end

  describe '#match_smp' do
    subject { parser.match_smp(defs, smp.split("\n")) }

    let(:smp) { '' }
    let(:f) { ->(*args) { AtCoderFriends::Problem::InputFormat.new(*args) } }

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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[1]).to have_attributes(
          item: :number, cols: %i[number] * 3
        )
        expect(defs[2]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[3]).to have_attributes(
          item: :number, cols: %i[number]
        )
      end
    end

    context 'for single(number)-harray(number)' do
      let(:defs) do
        [
          f[:single, nil, %w[N K], []],
          f[:harray, nil, %w[R], %w[N]]
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
        expect(defs[1]).to have_attributes(
          item: :number, cols: %i[number] * 10
        )
      end
    end

    context 'for single(number)-varray(string)' do
      let(:defs) do
        [
          f[:single, nil, %w[R C K], []],
          f[:varray, nil, %w[s], %w[R]]
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number] * 3
        )
        expect(defs[1]).to have_attributes(
          item: :string, cols: %i[string]
        )
      end
    end

    context 'for single(string)' do
      let(:defs) do
        [
          f[:single, nil, %w[X], []]
        ]
      end
      let(:smp) { 'atcoder' }
      it 'can detect type' do
        subject
        expect(defs[0]).to have_attributes(
          item: :string, cols: %i[string]
        )
      end
    end

    context 'for matrix(string)' do
      let(:defs) do
        [
          f[:matrix, nil, %w[c], %w[3 3]]
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
        expect(defs[0]).to have_attributes(
          item: :string, cols: %i[string] * 4
        )
      end
    end

    context 'for single(number)-matrix(char)' do
      let(:defs) do
        [
          f[:single, nil, %w[H W T], []],
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number] * 3
        )
        expect(defs[1]).to have_attributes(
          item: :char, cols: %i[string]
        )
      end
    end

    context 'for single(number)-harray(char)' do
      let(:defs) do
        [
          f[:single, nil, %w[N], []],
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[1]).to have_attributes(
          item: :char, cols: %i[number]
        )
      end
    end

    context 'for varray_matrix(number)' do
      let(:defs) do
        [
          f[:single, nil, %w[N M], []],
          f[:varray_matrix, nil, %w[K A], %w[N K_N]]
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
        expect(defs[1]).to have_attributes(
          item: :number, cols: %i[number] * 5
        )
      end
    end

    context 'for varray_matrix(char)' do
      let(:defs) do
        [
          f[:single, nil, %w[N], []],
          f[:varray, nil, %w[S], %w[N]],
          f[:single, nil, %w[Q], []],
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[1]).to have_attributes(
          item: :string, cols: %i[string]
        )
        expect(defs[2]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[3]).to have_attributes(
          item: :char, cols: %i[number string]
        )
      end
    end

    context 'for matrix_varray(number)' do
      let(:defs) do
        [
          f[:single, nil, %w[M], []],
          f[:matrix_varray, nil, %w[city cost], %w[M 2]]
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[1]).to have_attributes(
          item: :number, cols: %i[number] * 3
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:defs) do
        [
          f[:single, nil, %w[N M], []],
          f[:varray, nil, %w[C cost], %w[1]],
          f[:vmatrix, nil, %w[idol p], %w[1 C_1]]
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
        expect(defs[1]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
        expect(defs[2]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:defs) do
        [
          f[:single, nil, %w[N M Q], []],
          f[:matrix, :char, %w[S], %w[N M]],
          f[:hmatrix, nil, %w[x y], %w[Q 2]]
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
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number] * 3
        )
        expect(defs[1]).to have_attributes(
          item: :char, cols: %i[number]
        )
        expect(defs[2]).to have_attributes(
          item: :number, cols: %i[number] * 4
        )
      end
    end

    context 'for varray(decimal)' do
      let(:defs) do
        [
          f[:single, nil, %w[N], []],
          f[:varray, nil, %w[MT mT], %w[N]]
        ]
      end
      let(:smp) do
        <<~SMP
          4
          32.2 25.3
          36.4 26.4
          24.1 18.0
          26.0 24.9
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[1]).to have_attributes(
          item: :decimal, cols: %i[decimal] * 2
        )
      end
    end

    context 'for unknown format' do
      let(:defs) do
        [
          f[:unknown, '1']
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
        expect(defs[0]).to have_attributes(
          item: '1', cols: []
        )
      end
    end

    context 'for format with delimiters' do
      let(:defs) do
        [
          f[:single, nil, %w[N], []],
          f[:varray, nil, %w[S E], %w[N], '-']
        ]
      end
      let(:smp) do
        <<~SMP
          6
          1157-1306
          1159-1307
          1158-1259
          1230-1240
          1157-1306
          1315-1317
        SMP
      end
      it 'can detect type' do
        subject
        expect(defs[0]).to have_attributes(
          item: :number, cols: %i[number]
        )
        expect(defs[1]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
      end
    end
  end
end
