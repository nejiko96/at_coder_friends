# frozen_string_literal: true

RSpec.describe AtCoderFriends::Parser::SampleData do
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

    def smp_txt(ext, no)
      pbm.samples.find { |smp| smp.ext == ext && smp.no.to_i == no }&.txt
    end

    context 'for arc001_1' do
      let(:url) { '/contests/arc001/tasks/arc001_1' }

      it 'collects sample data' do
        subject
        expect(pbm.samples.count { |smp| smp.ext == :in }).to eq(3)
        expect(pbm.samples.count { |smp| smp.ext == :exp }).to eq(3)
        expect(smp_txt(:in, 1)).to eq("9\n131142143\n")
        expect(smp_txt(:exp, 1)).to eq("4 1\n")
        expect(smp_txt(:in, 2)).to eq("20\n12341234123412341234\n")
        expect(smp_txt(:exp, 2)).to eq("5 5\n")
        expect(smp_txt(:in, 3)).to eq("4\n1111\n")
        expect(smp_txt(:exp, 3)).to eq("4 0\n")
      end
    end

    context 'for tdpc_contest' do
      let(:url) { '/contests/tdpc/tasks/tdpc_contest' }

      it 'collects sample data' do
        subject
        expect(pbm.samples.count { |smp| smp.ext == :in }).to eq(2)
        expect(pbm.samples.count { |smp| smp.ext == :exp }).to eq(2)
        expect(smp_txt(:in, 1)).to eq("3\n2 3 5\n")
        expect(smp_txt(:exp, 1)).to eq("7\n")
        expect(smp_txt(:in, 2)).to eq("10\n1 1 1 1 1 1 1 1 1 1\n")
        expect(smp_txt(:exp, 2)).to eq("11\n")
      end
    end

    context 'for practice_2' do
      let(:url) { '/contests/practice/tasks/practice_2' }

      it 'collects sample data' do
        subject
        expect(pbm.samples.count { |smp| smp.ext == :in }).to eq(0)
        expect(pbm.samples.count { |smp| smp.ext == :exp }).to eq(0)
      end
    end
  end
end
