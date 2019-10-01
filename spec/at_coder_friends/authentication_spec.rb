# frozen_string_literal: true

RSpec.describe AtCoderFriends::CLI do
  include FileHelper

  subject(:cli) { described_class.new }

  describe 'user authentication' do
    include_context :uses_temp_dir
    include_context :atcoder_stub
    include_context :evacuate_session

    CONFIG_CONTENT = <<~TEXT
      user: foo
      password: bar
    TEXT

    SESSION_CONTENT = <<~TEXT
      ---
      atcoder.jp:
        "/":
          SessionKey: !ruby/object:Mechanize::Cookie
            name: SessionKey
            value: 4b12f708b5a219ec
            domain: atcoder.jp
            for_domain: false
            path: "/"
            secure: false
            httponly: false
            expires: Fri, 1 Jan 2038 00:00:00 GMT
            max_age:
            created_at: 2019-10-01 00:00:00.000000000 +09:00
            accessed_at: 2019-10-01 00:00:00.000000000 +09:00
    TEXT

    subject { cli.run(args) }
    let(:args) { ['setup', path] }
    let(:path) { File.join(temp_dir, 'practice') }

    shared_examples 'normal case' do
      it 'generates examples and sources' do
        expect { subject }.to output(
          <<~OUTPUT
            ***** fetch_all practice *****
            fetch list from https://atcoder.jp/contests/practice/tasks ...
            fetch problem from /contests/practice/tasks/practice_1 ...
            A_001.in
            A_001.exp
            A_002.in
            A_002.exp
            A.rb
            A.cxx
            fetch problem from /contests/practice/tasks/practice_2 ...
            B.rb
            B.cxx
          OUTPUT
        ).to_stdout
      end
    end

    context 'when auth info is set in .at_coder_friends.yml' do
      let(:sess_file) { File.join(sess_dir, 'foo_session.yml') }
      before(:each) do
        create_file(
          File.join(temp_dir, '.at_coder_friends.yml'),
          CONFIG_CONTENT
        )
      end

      context 'when session is not saved' do
        before(:each) { File.delete(sess_file) if File.exist?(sess_file) }

        it_behaves_like 'normal case'

        it 'saves session per user' do
          expect { subject }
            .to change { File.exist?(sess_file) }
            .from(false)
            .to(true)
        end
      end

      context 'when session is saved' do
        before(:each) do
          File.delete(sess_file) if File.exist?(sess_file)
          create_file(sess_file, SESSION_CONTENT)
          sleep 0.1
        end

        it 'loads session per user' do
          expect { subject }.to change { File.atime(sess_file) }
        end

        it_behaves_like 'normal case'
      end
    end

    context 'when auth info is not set in .at_coder_friends.yml' do
      let(:sess_file) { File.join(sess_dir, '_session.yml') }

      context 'when session is not saved' do
        before(:each) { File.delete(sess_file) if File.exist?(sess_file) }
        before(:each) do
          allow(STDIN).to receive(:gets) do
            input.shift.to_s + "\n"
          end
        end

        context 'when entered user/password is valid' do
          let(:input) { %w[foo bar] }

          it 'generates examples and sources' do
            expect { subject }.to output(
              <<~OUTPUT
                ***** fetch_all practice *****
                fetch list from https://atcoder.jp/contests/practice/tasks ...
                Enter username:Enter password for foo:
                fetch problem from /contests/practice/tasks/practice_1 ...
                A_001.in
                A_001.exp
                A_002.in
                A_002.exp
                A.rb
                A.cxx
                fetch problem from /contests/practice/tasks/practice_2 ...
                B.rb
                B.cxx
              OUTPUT
            ).to_stdout
          end

          it 'saves global session' do
            expect { subject }
              .to change { File.exist?(sess_file) }
              .from(false)
              .to(true)
          end
        end

        context 'when entered user/password is invalid' do
          let(:input) { %w[hoge piyo] }

          it 'shows error' do
            expect { subject }
              .to output("Authentication failed.\n")
              .to_stderr
            expect(subject).to eq(1)
          end
        end
      end

      context 'when session is saved' do
        before(:each) do
          File.delete(sess_file) if File.exist?(sess_file)
          create_file(sess_file, SESSION_CONTENT)
          sleep 0.1
        end

        it 'loads global session' do
          expect { subject }.to change { File.atime(sess_file) }
        end

        it_behaves_like 'normal case'
      end
    end
  end
end
