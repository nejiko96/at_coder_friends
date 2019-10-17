# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::Constraints do
  subject(:parser) do
    described_class
  end

  describe '#process' do
    include_context :atcoder_env
    include_context :atcoder_stub

    subject { parser.process(pbm) }

    let(:pbm) do
      agent
        .fetch_problem('A', File.join('https://atcoder.jp/', url))
        .tap { |pbm| AtCoderFriends::Parser::Sections.process(pbm) }
    end
    let(:agent) { AtCoderFriends::Scraping::Agent.new(ctx) }
    let(:ctx) { AtCoderFriends::Context.new({}, contest_root) }

    context 'for arc001_1' do
      let(:url) { '/contests/arc001/tasks/arc001_1' }

      it 'parses constraints' do
        subject
        expect(pbm.constraints.size).to eq(1)
        expect(pbm.constraints[0]).to have_attributes(
          name: 'N', type: :max, value: 100
        )
      end
    end

    context 'for tdpc_contest' do
      let(:url) { '/contests/tdpc/tasks/tdpc_contest' }

      it 'parses constraints' do
        subject
        expect(pbm.constraints.size).to eq(2)
        expect(pbm.constraints[0]).to have_attributes(
          name: 'N', type: :max, value: 100
        )
        expect(pbm.constraints[1]).to have_attributes(
          name: 'p_i', type: :max, value: 100
        )
      end
    end

    context 'for practice_2' do
      let(:url) { '/contests/practice/tasks/practice_2' }

      it 'parses constraints' do
        subject
        expect(pbm.constraints.size).to eq(0)
      end
    end
  end

  describe '#parse' do
    subject { parser.parse(desc) }

    context 'normal case' do
      let(:desc) do
        <<~DESC
          1 行目には、村の個数を表した整数 N (2 ≦ N ≦ 10^4) と、
          道の本数を表した整数 M (1 ≦ M ≦ 10^4) が空白区切りで与えられる。
          続く M 行には、道の情報が与えられる。
          このうちの i 行目には 4 つの整数
          A_i (0 ≦ A_i ≦ N-1), B_i (0 ≦ B_i ≤ N-1),
          C_i (1 ≤ C_i leq 10^6), T_i (1 leq T_i le 10^6)
          が空白区切りで書かれており、これは 村 A_i と村 B_i を繋ぐ道があり、
          この道を修理するために費用が C_i、時間が T_i かかることを表している。
        DESC
      end

      it 'parses constraints' do
        expect(subject.size).to eq(4)
        expect(subject[0]).to have_attributes(
          name: 'N', type: :max, value: 10_000
        )
        expect(subject[1]).to have_attributes(
          name: 'M', type: :max, value: 10_000
        )
        expect(subject[2]).to have_attributes(
          name: 'C_i', type: :max, value: 1_000_000
        )
        expect(subject[3]).to have_attributes(
          name: 'T_i', type: :max, value: 1_000_000
        )
      end
    end
  end
end
