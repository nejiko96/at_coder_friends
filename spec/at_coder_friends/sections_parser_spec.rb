# frozen_string_literal: true

require 'mechanize'

RSpec.describe AtCoderFriends::Parser::Sections do
  subject(:parser) do
    described_class
  end

  describe '#process' do
    include_context :atcoder_env
    include_context :atcoder_stub

    subject { parser.process(pbm) }

    let(:pbm) do
      agent.fetch_problem('A', File.join('https://atcoder.jp/', url))
    end
    let(:agent) { AtCoderFriends::Scraping::Agent.new(ctx) }
    let(:ctx) { AtCoderFriends::Context.new({}, contest_root) }

    context 'for arc001_1' do
      let(:url) { '/contests/arc001/tasks/arc001_1' }

      it 'collect sections from page' do
        subject
        expect(pbm.sections.keys).to match_array(
          %w[
            INTRODUCTION STATEMENT
            INPUT_FORMAT OUTPUT_FORMAT
            INPUT_SAMPLE_1 INPUT_SAMPLE_2 INPUT_SAMPLE_3
            OUTPUT_SAMPLE_1 OUTPUT_SAMPLE_2 OUTPUT_SAMPLE_3
          ]
        )
      end
    end

    context 'for tdpc_contest' do
      let(:url) { '/contests/tdpc/tasks/tdpc_contest' }

      it 'collect sections from page' do
        subject
        expect(pbm.sections.keys).to match_array(
          %w[
            INTRODUCTION STATEMENT
            INPUT_FORMAT OUTPUT_FORMAT CONSTRAINTS
            INPUT_SAMPLE_1 INPUT_SAMPLE_2
            OUTPUT_SAMPLE_1 OUTPUT_SAMPLE_2
          ]
        )
      end
    end

    context 'for practice_2' do
      let(:url) { '/contests/practice/tasks/practice_2' }

      it 'collect sections from page' do
        subject
        expect(pbm.sections.keys).to match_array(
          %w[INTRODUCTION STATEMENT CONSTRAINTS INOUT_FORMAT INOUT_SAMPLE]
        )
      end
    end
  end
end
