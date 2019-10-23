# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::Modulo do
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

    context 'for abc003_4' do
      let(:url) { '/contests/abc003/tasks/abc003_4' }

      it 'parses modulo values' do
        subject
        expect(pbm.constants.size).to eq(1)
        expect(pbm.constants[0]).to have_attributes(
          name: nil, type: :mod, value: '1000000007'
        )
      end
    end

    context 'for practice_2' do
      let(:url) { '/contests/practice/tasks/practice_2' }

      it 'parses modulo values' do
        subject
        expect(pbm.constants.size).to eq(0)
      end
    end
  end
end
