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
        expect(subject).to eq(%w[4049 3024])
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
            3003 - C++14 (GCC 5.4.1)
            3001 - Bash (GNU bash v4.3.11)
            3002 - C (GCC 5.4.1)
            3004 - C (Clang 3.8.0)
            3005 - C++14 (Clang 3.8.0)
            3006 - C# (Mono 4.6.2.0)
            3007 - Clojure (1.8.0)
            3008 - Common Lisp (SBCL 1.1.14)
            3009 - D (DMD64 v2.070.1)
            3010 - D (LDC 0.17.0)
            3011 - D (GDC 4.9.4)
            3012 - Fortran (gfortran v4.8.4)
            3013 - Go (1.6)
            3014 - Haskell (GHC 7.10.3)
            3015 - Java7 (OpenJDK 1.7.0)
            3016 - Java8 (OpenJDK 1.8.0)
            3017 - JavaScript (node.js v5.12)
            3018 - OCaml (4.02.3)
            3019 - Pascal (FPC 2.6.2)
            3020 - Perl (v5.18.2)
            3021 - PHP (5.6.30)
            3022 - Python2 (2.7.6)
            3023 - Python3 (3.4.3)
            3024 - Ruby (2.3.3)
            3025 - Scala (2.11.7)
            3026 - Scheme (Gauche 0.9.3.3)
            3027 - Text (cat)
            3028 - Visual Basic (Mono 4.0.1)
            3029 - C++ (GCC 5.4.1)
            3030 - C++ (Clang 3.8.0)
            3501 - Objective-C (GCC 5.3.0)
            3502 - Objective-C (Clang3.8.0)
            3503 - Swift (swift-2.2-RELEASE)
            3504 - Rust (1.15.1)
            3505 - Sed (GNU sed 4.2.2)
            3506 - Awk (mawk 1.3.3)
            3507 - Brainfuck (bf 20041219)
            3508 - Standard ML (MLton 20100608)
            3509 - PyPy2 (5.6.0)
            3510 - PyPy3 (2.4.0)
            3511 - Crystal (0.20.5)
            3512 - F# (Mono 4.0)
            3513 - Unlambda (0.1.3)
            3514 - Lua (5.3.2)
            3515 - LuaJIT (2.0.4)
            3516 - MoonScript (0.5.0)
            3517 - Ceylon (1.2.1)
            3518 - Julia (0.5.0)
            3519 - Octave (4.0.2)
            3520 - Nim (0.13.0)
            3521 - TypeScript (2.1.6)
            3522 - Perl6 (rakudo-star 2016.01)
            3523 - Kotlin (1.0.0)
            3524 - PHP7 (7.0.15)
            3525 - COBOL - Fixed (OpenCOBOL 1.1.0)
            3526 - COBOL - Free (OpenCOBOL 1.1.0)
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
