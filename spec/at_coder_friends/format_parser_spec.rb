# frozen_string_literal: true

RSpec.describe AtCoderFriends::FormatParser do
  subject(:parser) do
    described_class.new
  end

  # let(:pbm) do
  #   pbm = AtCoderFriends::Problem.new
  #   pbm.fmt = fmt
  #   pbm.add_smp(1, :in, '0')
  #   pbm.add_smp(1, :exp, 'YES')
  #   pbm.add_smp(2, :in, smp)
  # end

  # let(:fmt) { '' }
  # let(:smp) { '' }

  describe '#parse_fmt' do
    it 'can parse multiple format' do
      fmt = <<~EOS
        N M P Q R
        x_1 y_1 z_1
        x_2 y_2 z_2
        :
        x_R y_R z_R
      EOS
      smp = <<~EOS
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
      EOS
      def0 = AtCoderFriends::InputDef.new(:single, nil, :number, %w[N M P Q R])
      def1 = AtCoderFriends::InputDef.new(:varray, 'R', :number, %w[X Y Z])
      defs = parser.parse_fmt(fmt)
      p defs
      expect(defs.size).to eq(2)
      expect(defs[0]).to eq(def0)
      expect(defs[1]).to eq(def1)
    end
  end
end
