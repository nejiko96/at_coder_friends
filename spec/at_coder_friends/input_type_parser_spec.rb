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
    let(:defs) do
      def_params.map { |h| AtCoderFriends::Problem::InputFormat.new(h) }
    end
    let(:smp) { '' }

    context 'for single(number)-matrix(number)-single(number)-varray(number)' do
      let(:def_params) do
        [
          { container: :single, names: %w[N] },
          { container: :matrix, names: %w[D], size: %w[N N] },
          { container: :single, names: %w[Q] },
          { container: :varray, names: %w[P], size: %w[Q] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N K] },
          { container: :harray, names: %w[R], size: %w[N] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[R C K] },
          { container: :varray, names: %w[s], size: %w[R] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[X] }
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
      let(:def_params) do
        [
          { container: :matrix, names: %w[c], size: %w[3 3] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[H W T] },
          { container: :matrix, item: :char, names: %w[s], size: %w[H W] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N] },
          { container: :harray, item: :char, names: %w[c], size: %w[N] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N M] },
          { container: :varray_matrix, names: %w[K A], size: %w[N K_N] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N] },
          { container: :varray, names: %w[S], size: %w[N] },
          { container: :single, names: %w[Q] },
          {
            container: :varray_matrix, item: :char,
            names: %w[k p], size: %w[Q 26]
          }
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
      let(:def_params) do
        [
          { container: :single, names: %w[M] },
          { container: :matrix_varray, names: %w[city cost], size: %w[M 2] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N M] },
          { container: :varray, names: %w[C cost], size: %w[1] },
          { container: :vmatrix, names: %w[idol p], size: %w[1 C_1] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N M Q] },
          { container: :matrix, item: :char, names: %w[S], size: %w[N M] },
          { container: :hmatrix, names: %w[x y], size: %w[Q 2] }
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
      let(:def_params) do
        [
          { container: :single, names: %w[N] },
          { container: :varray, names: %w[MT mT], size: %w[N] }
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
      let(:def_params) do
        [
          { container: :unknown, item: '1' }
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
          item: '1', cols: [:number]
        )
      end
    end

    context 'for format with delimiters' do
      let(:def_params) do
        [
          { container: :single, names: %w[N] },
          { container: :varray, names: %w[S E], size: %w[N], delim: '-' }
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

    context 'for N-1 lines input' do
      let(:def_params) do
        [
          { container: :single, names: %w[N] },
          { container: :varray, names: %w[a b c], size: %w[N-1] },
          { container: :single, names: %w[Q K] },
          { container: :varray, names: %w[x y], size: %w[Q] }
        ]
      end
      let(:smp) do
        <<~SMP
          10
          1 2 1000000000
          2 3 1000000000
          3 4 1000000000
          4 5 1000000000
          5 6 1000000000
          6 7 1000000000
          7 8 1000000000
          8 9 1000000000
          9 10 1000000000
          1 1
          9 10
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
          item: :number, cols: %i[number] * 2
        )
        expect(defs[3]).to have_attributes(
          item: :number, cols: %i[number] * 2
        )
      end
    end
  end
end
