# frozen_string_literal: true

RSpec.describe AtCoderFriends::Problem::InputFormat do
  subject(:inpdef) { described_class.new(params) }

  describe '#to_s' do
    subject { inpdef.to_s }

    context 'for normal format' do
      let(:params) do
        {
          container: :matrix,
          item: :number,
          names: %w[A],
          size: %w[H W],
          cols: %i[number] * 2
        }
      end

      it 'returns format description' do
        expect(subject).to eq(
          'matrix number([:number, :number]) ["A"] ["H", "W"] '
        )
      end
    end

    context 'for format with delimiter' do
      let(:params) do
        {
          container: :varray,
          item: :number,
          names: %w[S E],
          size: %w[N],
          cols: %i[number] * 2,
          delim: '-'
        }
      end

      it 'returns format description' do
        expect(subject).to eq(
          'varray number([:number, :number]) ["S", "E"] ["N"] -'
        )
      end
    end

    context 'for unknown format' do
      let(:params) do
        {
          container: :unknown,
          item: 'クエリ1'
        }
      end

      it 'returns format description' do
        expect(subject).to eq(
          'unknown クエリ1'
        )
      end
    end
  end
end
