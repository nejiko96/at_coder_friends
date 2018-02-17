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
      expect(File.exist?(f['data/A_001.in'])).to be true
      expect(File.exist?(f['data/A_001.exp'])).to be true
      expect(File.exist?(f['A.rb'])).to be true
      expect(File.exist?(f['A.cxx'])).to be true
      expect(File.read(f['data/A_001.in'])).to eq('content of A_001.in')
      expect(File.read(f['data/A_001.exp'])).to eq('content of A_001.exp')
      expect(File.read(f['A.rb'])).to eq('content of A.rb')
      expect(File.read(f['A.cxx'])).to eq('content of A.cxx')
    end
  end
end
