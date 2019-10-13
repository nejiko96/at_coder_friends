# frozen_string_literal: true

require 'mechanize'

RSpec.describe AtCoderFriends::Parser::PageParser do
  include_context :atcoder_stub

  subject(:parser) do
    described_class
  end

  describe '#process' do
    subject { parser.process(pbm) }

    before(:all) { @agent = Mechanize.new }
    let(:pbm) { AtCoderFriends::Problem.new(q) { |pbm| pbm.page = page } }
    let(:q) { 'A' }
    let(:page) { @agent.get(File.join('https://atcoder.jp/', url)) }

    context 'for problem in arc001' do
      let(:url) { '/contests/arc001/tasks/arc001_1' }

      it 'parses page content' do
        subject
        expect(pbm.desc).not_to eq('')
        expect(pbm.fmt).not_to eq('')
        expect(pbm.smps.count { |smp| smp.ext == :in }).to eq(3)
        expect(pbm.smps.count { |smp| smp.ext == :exp }).to eq(3)
      end
    end

    context 'for problem in tdpc' do
      let(:url) { '/contests/tdpc/tasks/tdpc_contest' }

      it 'parses page content' do
        subject
        expect(pbm.desc).not_to eq('')
        expect(pbm.fmt).not_to eq('')
        expect(pbm.smps.count { |smp| smp.ext == :in }).to eq(2)
        expect(pbm.smps.count { |smp| smp.ext == :exp }).to eq(2)
      end
    end
  end
end
