# frozen_string_literal: true

require 'fileutils'

module AtCoderFriends
  # emits source skeletons and sample input/output(s)
  # of a problem to the specified directory.
  class Emitter
    include PathUtil

    def initialize(ctx)
      @src_dir = ctx.path_info.src_dir
      @smp_dir = ctx.path_info.smp_dir
    end

    def emit(pbm)
      pbm.samples.each { |smp| emit_sample(pbm, smp) }
      pbm.sources.each { |src| emit_source(pbm, src) }
    end

    def emit_sample(pbm, smp)
      makedirs_unless @smp_dir
      smp_file = format(
        '%<q>s_%<n>03d.%<ext>s', q: pbm.q, n: smp.no, ext: smp.ext
      )
      smp_path = File.join(@smp_dir, smp_file)
      File.write(smp_path, smp.txt)
      puts smp_file
    end

    def emit_source(pbm, src)
      makedirs_unless @src_dir
      src_file = format('%<q>s.%<ext>s', q: pbm.q, ext: src.ext)
      src_path = File.join(@src_dir, src_file)
      File.write(src_path, src.txt)
      puts src_file
    end
  end
end
