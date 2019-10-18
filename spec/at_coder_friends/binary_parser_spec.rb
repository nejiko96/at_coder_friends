# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::Binary do
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
        .tap do |pbm|
          AtCoderFriends::Parser::Sections.process(pbm)
          AtCoderFriends::Parser::SampleData.process(pbm)
        end
    end
    let(:agent) { AtCoderFriends::Scraping::Agent.new(ctx) }
    let(:ctx) { AtCoderFriends::Context.new({}, contest_root) }

    context 'for arc001_1' do
      let(:url) { '/contests/arc001/tasks/arc001_1' }

      it 'detects binary broblem' do
        subject
        expect(pbm.options.binary_values).to be nil
      end
    end

    context 'for arc002_1' do
      let(:url) { '/contests/arc002/tasks/arc002_1' }

      it 'detects binary broblem' do
        subject
        expect(pbm.options.binary_values).to match %w[YES NO]
      end
    end
  end
end
