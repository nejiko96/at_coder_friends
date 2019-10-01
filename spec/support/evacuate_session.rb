# frozen_string_literal: true

shared_context :evacuate_session do
  include FileHelper

  before :all do
    @sess_dir = File.join(Dir.home, '.at_coder_friends')
    @bak_dir = File.join(Dir.home, '.at_coder_friends_bak_' + SecureRandom.hex)
    rmdir_force(bak_dir)
    FileUtils.mv(sess_dir, bak_dir) if Dir.exist?(sess_dir)
  end

  after :all do
    rmdir_force(sess_dir)
    FileUtils.mv(bak_dir, sess_dir) if Dir.exist?(bak_dir)
  end

  attr_reader :sess_dir, :bak_dir
end
