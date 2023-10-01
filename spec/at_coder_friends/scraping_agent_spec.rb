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
            logged in as ねじこ (Guest)
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
            logged in as ねじこ (Contestant)
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
              logged in as ねじこ (Contestant)
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
              logged in as ねじこ (Contestant)
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
            5001 - C++ 20 (gcc 12.2)
            5002 - Go (go 1.20.6)
            5003 - C# 11.0 (.NET 7.0.7)
            5004 - Kotlin (Kotlin/JVM 1.8.20)
            5005 - Java (OpenJDK 17)
            5006 - Nim (Nim 1.6.14)
            5007 - V (V 0.4)
            5008 - Zig (Zig 0.10.1)
            5009 - JavaScript (Node.js 18.16.1)
            5010 - JavaScript (Deno 1.35.1)
            5011 - R (GNU R 4.2.1)
            5012 - D (DMD 2.104.0)
            5013 - D (LDC 1.32.2)
            5014 - Swift (swift 5.8.1)
            5015 - Dart (Dart 3.0.5)
            5016 - PHP (php 8.2.8)
            5017 - C (gcc 12.2.0)
            5018 - Ruby (ruby 3.2.2)
            5019 - Crystal (Crystal 1.9.1)
            5020 - Brainfuck (bf 20041219)
            5021 - F# 7.0 (.NET 7.0.7)
            5022 - Julia (Julia 1.9.2)
            5023 - Bash (bash 5.2.2)
            5024 - Text (cat 8.32)
            5025 - Haskell (GHC 9.4.5)
            5026 - Fortran (gfortran 12.2)
            5027 - Lua (LuaJIT 2.1.0-beta3)
            5028 - C++ 23 (gcc 12.2)
            5029 - Common Lisp (SBCL 2.3.6)
            5030 - COBOL (Free) (GnuCOBOL 3.1.2)
            5031 - C++ 23 (Clang 16.0.6)
            5032 - Zsh (Zsh 5.9)
            5033 - SageMath (SageMath 9.5)
            5034 - Sed (GNU sed 4.8)
            5035 - bc (bc 1.07.1)
            5036 - dc (dc 1.07.1)
            5037 - Perl (perl  5.34)
            5038 - AWK (GNU Awk 5.0.1)
            5039 - なでしこ (cnako3 3.4.20)
            5040 - Assembly x64 (NASM 2.15.05)
            5041 - Pascal (fpc 3.2.2)
            5042 - C# 11.0 AOT (.NET 7.0.7)
            5043 - Lua (Lua 5.4.6)
            5044 - Prolog (SWI-Prolog 9.0.4)
            5045 - PowerShell (PowerShell 7.3.1)
            5046 - Scheme (Gauche 0.9.12)
            5047 - Scala 3.3.0 (Scala Native 0.4.14)
            5048 - Visual Basic 16.9 (.NET 7.0.7)
            5049 - Forth (gforth 0.7.3)
            5050 - Clojure (babashka 1.3.181)
            5051 - Erlang (Erlang 26.0.2)
            5052 - TypeScript 5.1 (Deno 1.35.1)
            5053 - C++ 17 (gcc 12.2)
            5054 - Rust (rustc 1.70.0)
            5055 - Python (CPython 3.11.4)
            5056 - Scala (Dotty 3.3.0)
            5057 - Koka (koka 2.4.0)
            5058 - TypeScript 5.1 (Node.js 18.16.1)
            5059 - OCaml (ocamlopt 5.0.0)
            5060 - Raku (Rakudo 2023.06)
            5061 - Vim (vim 9.0.0242)
            5062 - Emacs Lisp (Native Compile) (GNU Emacs 28.2)
            5063 - Python (Mambaforge / CPython 3.10.10)
            5064 - Clojure (clojure 1.11.1)
            5065 - プロデル (mono版プロデル 1.9.1182)
            5066 - ECLiPSe (ECLiPSe 7.1_13)
            5067 - Nibbles (literate form) (nibbles 1.01)
            5068 - Ada (GNAT 12.2)
            5069 - jq (jq 1.6)
            5070 - Cyber (Cyber v0.2-Latest)
            5071 - Carp (Carp 0.5.5)
            5072 - C++ 17 (Clang 16.0.6)
            5073 - C++ 20 (Clang 16.0.6)
            5074 - LLVM IR (Clang 16.0.6)
            5075 - Emacs Lisp (Byte Compile) (GNU Emacs 28.2)
            5076 - Factor (Factor 0.98)
            5077 - D (GDC 12.2)
            5078 - Python (PyPy 3.10-v7.3.12)
            5079 - Whitespace (whitespacers 1.0.0)
            5080 - ><> (fishr 0.1.0)
            5081 - ReasonML (reason 3.9.0)
            5082 - Python (Cython 0.29.34)
            5083 - Octave (GNU Octave 8.2.0)
            5084 - Haxe (JVM) (Haxe 4.3.1)
            5085 - Elixir (Elixir 1.15.2)
            5086 - Mercury (Mercury 22.01.6)
            5087 - Seed7 (Seed7 3.2.1)
            5088 - Emacs Lisp (No Compile) (GNU Emacs 28.2)
            5089 - Unison (Unison M5b)
            5090 - COBOL (GnuCOBOL(Fixed) 3.1.2)
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
