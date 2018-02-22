# frozen_string_literal: true

RSpec.describe AtCoderFriends::Emitter do
  subject(:emitter) { described_class.new(dir) }
  let(:pbm) do
    AtCoderFriends::Problem.new('A') do |pbm|
      pbm.add_smp('1', :in, 'content of A_001.in')
      pbm.add_smp('1', :exp, 'content of A_001.exp')
      pbm.add_src(:rb, 'content of A.rb')
      pbm.add_src(:cxx, 'content of A.cxx')
    end
  end
  let(:f) { ->(file) { File.join(dir, file) } }
  let(:e) { ->(file) { File.exist?(f[file]) } }
  let(:c) { ->(file) { File.read(f[file]) } }

  describe '#emit' do
    include_context :uses_temp_dir

    subject { emitter.emit(pbm) }
    let(:dir) { temp_dir }

    it 'writes files' do
      expect { subject }.to output(
        <<~OUTPUT
          A_001.in
          A_001.exp
          A.rb
          A.cxx
        OUTPUT
      ).to_stdout
      expect(e['data/A_001.in']).to be true
      expect(e['data/A_001.exp']).to be true
      expect(e['A.rb']).to be true
      expect(e['A.cxx']).to be true
      expect(c['data/A_001.in']).to eq('content of A_001.in')
      expect(c['data/A_001.exp']).to eq('content of A_001.exp')
      expect(c['A.rb']).to eq('content of A.rb')
      expect(c['A.cxx']).to eq('content of A.cxx')
    end
  end
end
