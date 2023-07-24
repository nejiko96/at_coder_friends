# frozen_string_literal: true

RSpec.describe AtCoderFriends::Scraping::Agent do
  include_context :atcoder_env
  include_context :atcoder_stub

  subject(:agent) { described_class.new(ctx) }
  let(:ctx) { AtCoderFriends::Context.new({}, path) }

  describe '#fetch_all' do
    subject { agent.fetch_all }
    let(:path) { File.join(project_root, contest) }

    # TODO: yield test
    context 'from ARC#001' do
      let(:contest) { 'arc001' }

      it 'fetches problems' do
        expect { subject }.to output(
          <<~TEXT
            ***** fetch_all arc001 *****
            fetch list from https://atcoder.jp/contests/arc001/tasks ...
            fetch problem from /contests/arc001/tasks/arc001_1 ...
            fetch problem from /contests/arc001/tasks/arc001_2 ...
            fetch problem from /contests/arc001/tasks/arc001_3 ...
            fetch problem from /contests/arc001/tasks/arc001_4 ...
          TEXT
        ).to_stdout
        expect(subject.size).to eq(4)
        expect(subject[0]).to have_attributes(q: 'A')
        expect(subject[1]).to have_attributes(q: 'B')
        expect(subject[2]).to have_attributes(q: 'C')
        expect(subject[3]).to have_attributes(q: 'D')
      end
    end

    context 'from practice' do
      let(:contest) { 'practice' }

      it 'fetches problems' do
        expect { subject }.to output(
          <<~TEXT
            ***** fetch_all practice *****
            fetch list from https://atcoder.jp/contests/practice/tasks ...
            logged in as foo (Contestant)
            fetch problem from /contests/practice/tasks/practice_1 ...
            fetch problem from /contests/practice/tasks/practice_2 ...
          TEXT
        ).to_stdout
        expect(subject.size).to eq(2)
        expect(subject[0]).to have_attributes(q: 'A')
        expect(subject[1]).to have_attributes(q: 'B')
      end
    end
  end

  describe '#submit' do
    subject { agent.submit }
    let(:path) { File.join(contest_root, prg) }

    context 'with no errors' do
      let(:prg) { 'A.rb' }

      it 'posts the source' do
        expect { subject }.to \
          output(
            <<~OUTPUT
              ***** submit A.rb *****
              logged in as foo (Contestant)
            OUTPUT
          ).to_stdout
        expect(subject).to be_a(Mechanize::Page)
      end
    end

    context 'for alt version' do
      let(:prg) { 'A_v2.rb' }

      it 'posts the source' do
        expect { subject }.to \
          output(
            <<~OUTPUT
              ***** submit A_v2.rb *****
              logged in as foo (Contestant)
            OUTPUT
          ).to_stdout
        expect(subject).to be_a(Mechanize::Page)
      end
    end

    context 'for non-existent problem' do
      let(:prg) { 'Z.rb' }

      it 'shows error' do
        expect { subject }.to \
          raise_error(AtCoderFriends::AppError, 'unknown problem:Z.')
      end
    end
  end

  describe '#code_test' do
    subject { agent.code_test(infile) }
    let(:path) { File.join(contest_root, prg) }

    let(:prg) { 'A.py' }
    let(:infile) { File.join(smp_dir, 'A_001.in') }
    let(:expfile) { File.join(smp_dir, 'A_001.exp') }

    context 'with no errors' do
      it 'returns result' do
        expect(subject['Result']['ExitCode']).to eq 0
        expect(subject['Stdout']).to eq File.read(expfile)
      end
    end

    context 'when server error occured' do
      it 'shows error' do
        allow(ctx).to receive(:config) do
          AtCoderFriends::ConfigLoader
            .load_config(ctx)
            .merge(
              'ext_settings' => {
                'py' => {
                  'submit_lang' => '0000'
                }
              }
            )
        end

        expect { subject }.to raise_error(
          AtCoderFriends::AppError, "Internal Error\n"
        )
      end
    end
  end

  describe '#lang_id' do
    subject { agent.lang_id(ext) }
    let(:path) { File.join(contest_root, 'A.rb') }

    context 'when submit_lang is spscified' do
      let(:ext) { 'rb' }

      it 'returns LanguageId' do
        expect(subject).to eq(%w[4049 5018])
      end
    end

    context 'when submit_lang is not specified' do
      let(:ext) { 'zzz' }

      it 'shows error' do
        expect { subject }.to raise_error(
          AtCoderFriends::AppError,
          <<~MSG
            submit_lang for .zzz is not specified.
            Available languages:
            4001 - C (GCC 9.2.1)
            4002 - C (Clang 10.0.0)
            4003 - C++ (GCC 9.2.1)
            4004 - C++ (Clang 10.0.0)
            4005 - Java (OpenJDK 11.0.6)
            4006 - Python (3.8.2)
            4007 - Bash (5.0.11)
            4008 - bc (1.07.1)
            4009 - Awk (GNU Awk 4.1.4)
            4010 - C# (.NET Core 3.1.201)
            4011 - C# (Mono-mcs 6.8.0.105)
            4012 - C# (Mono-csc 3.5.0)
            4013 - Clojure (1.10.1.536)
            4014 - Crystal (0.33.0)
            4015 - D (DMD 2.091.0)
            4016 - D (GDC 9.2.1)
            4017 - D (LDC 1.20.1)
            4018 - Dart (2.7.2)
            4019 - dc (1.4.1)
            4020 - Erlang (22.3)
            4021 - Elixir (1.10.2)
            4022 - F# (.NET Core 3.1.201)
            4023 - F# (Mono 10.2.3)
            4024 - Forth (gforth 0.7.3)
            4025 - Fortran(GNU Fortran 9.2.1)
            4026 - Go (1.14.1)
            4027 - Haskell (GHC 8.8.3)
            4028 - Haxe (4.0.3); js
            4029 - Haxe (4.0.3); Java
            4030 - JavaScript (Node.js 12.16.1)
            4031 - Julia (1.4.0)
            4032 - Kotlin (1.3.71)
            4033 - Lua (Lua 5.3.5)
            4034 - Lua (LuaJIT 2.1.0)
            4035 - Dash (0.5.8)
            4036 - Nim (1.0.6)
            4037 - Objective-C (Clang 10.0.0)
            4038 - Common Lisp (SBCL 2.0.3)
            4039 - OCaml (4.10.0)
            4040 - Octave (5.2.0)
            4041 - Pascal (FPC 3.0.4)
            4042 - Perl (5.26.1)
            4043 - Raku (Rakudo 2020.02.1)
            4044 - PHP (7.4.4)
            4045 - Prolog (SWI-Prolog 8.0.3)
            4046 - PyPy2 (7.3.0)
            4047 - PyPy3 (7.3.0)
            4048 - Racket (7.6)
            4049 - Ruby (2.7.1)
            4050 - Rust (1.42.0)
            4051 - Scala (2.13.1)
            4052 - Java (OpenJDK 1.8.0)
            4053 - Scheme (Gauche 0.9.9)
            4054 - Standard ML (MLton 20130715)
            4055 - Swift (5.2.1)
            4056 - Text (cat 8.28)
            4057 - TypeScript (3.8)
            4058 - Visual Basic (.NET Core 3.1.101)
            4059 - Zsh (5.4.2)
            4060 - COBOL - Fixed (OpenCOBOL 1.1.0)
            4061 - COBOL - Free (OpenCOBOL 1.1.0)
            4062 - Brainfuck (bf 20041219)
            4063 - Ada2012 (GNAT 9.2.1)
            4064 - Unlambda (2.0.0)
            4065 - Cython (0.29.16)
            4066 - Sed (4.4)
            4067 - Vim (8.2.0460)
          MSG
        )
      end

      context 'when failed to fetch language list' do
        before do
          allow(agent).to receive(:lang_list) { nil }
        end

        it 'shows error' do
          expect { subject }.to raise_error(
            AtCoderFriends::AppError,
            <<~MSG
              submit_lang for .zzz is not specified.
              Available languages:
              (failed to fetch)
            MSG
          )
        end
      end
    end
  end
end
