# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::Interactive do
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

      it 'detects interactive broblem' do
        subject
        expect(pbm.options.interactive).to be false
      end
    end

    context 'for tdpc_contest' do
      let(:url) { '/contests/tdpc/tasks/tdpc_contest' }
      it 'detects interactive broblem' do
        subject
        expect(pbm.options.interactive).to be false
      end
    end

    context 'for practice_2' do
      let(:url) { '/contests/practice/tasks/practice_2' }
      it 'detects interactive broblem' do
        subject
        expect(pbm.options.interactive).to be true
      end
    end
  end
end
