# Configuration details

## Configuration file

You can specify AtCoderFriends settings  
in the configuration file ```.at_coder_friends.yml```.  
Place it in your working directory (or higher).

AtCoderFriends の動作に関する設定は  
設定ファイル ```.at_coder_friends.yml``` に記述します。  
このファイルは作業ディレクトリ（またはその上位ディレクトリ）に配置します。

## Default settings

The default settings are as follows.  
If you add new settings or change existing settings in ```.at_coder_friends.yml```,  
Its contents are merged with the default settings.

デフォルトの設定は以下のようになっています。  
```.at_coder_friends.yml```で新しい設定項目の追加や、既存の設定項目の変更をすると、  
その内容がデフォルト設定にマージされます。

[/config/default.yml](/config/default.yml)

```YAML
user: ~
password: ~
generators:
  - RubyBuiltin
  - CxxBuiltin
ext_settings:
  'awk':
    submit_lang: '3506' # Awk (mawk)
  'bf':
    submit_lang: '3507' # Brainfuck
  'c':
    submit_lang: '3002' # C (GCC)
    test_cmd:
      default: '"{dir}/{base}"'
      windows: '"{dir}/{base}.exe"'
  'cbl':
    submit_lang: '3526' # COBOL - Free
  'clj':
    submit_lang: '3007' # Clojure
  'cr':
    submit_lang: '3511' # Crystal
  'cs':
    submit_lang: '3006' # C# (Mono)
    test_cmd:
      default: 'mono "{dir}/{base}.exe"'
      windows: '"{dir}/{base}.exe"'
  'cxx':
    submit_lang: '3003' # C++14 (GCC)
    test_cmd:
      default: '"{dir}/{base}"'
      windows: '"{dir}/{base}.exe"'
  'd':
    submit_lang: '3009' # D (DMD64)
  'f90':
    submit_lang: '3012' # Fortran (gfortran)
  'fs':
    submit_lang: '3512' # F# (Mono)
  'go':
    submit_lang: '3013' # Go
  'hs':
    submit_lang: '3014' # Haskell (GHC)
  'java':
    submit_lang: '3016' # Java8 (OpenJDK)
    test_cmd:
      default: 'java -cp "{dir}" Main'
  'jl':
    submit_lang: '3518' # Julia
  'js':
    submit_lang: '3017' # JavaScript (node.js)
  'kt':
    submit_lang: '3523' # Kotlin
  'lisp':
    submit_lang: '3008' # Common Lisp
  'lua':
    submit_lang: '3515' # LuaJIT
  'm':
    submit_lang: '3519' # Octave
  'ml':
    submit_lang: '3018' # OCaml
  'nim':
    submit_lang: '3520' # Nim
  'pas':
    submit_lang: '3019' # Pascal (FPC)
  'php':
    submit_lang: '3524' # PHP7
  'pl':
    submit_lang: '3020' # Perl
  'py':
    submit_lang: '3023' # Python3
  'rb':
    submit_lang: '3024' # Ruby
    test_cmd:
      default: 'ruby "{dir}/{base}.rb"'
  'rs':
    submit_lang: '3504' # Rust
  'scala':
    submit_lang: '3025' # Scala
  'scm':
    submit_lang: '3026' # Scheme (Gauche)
  'sed':
    submit_lang: '3505' # Sed (GNU sed)
  'sh':
    submit_lang: '3001' # Bash (GNU bash)
  'swift':
    submit_lang: '3503' # Swift
  'ts':
    submit_lang: '3521' # TypeScript
  'txt':
    submit_lang: '3027' # Text (cat)
  'vb':
    submit_lang: '3028' # Visual Basic (Mono)
```

## Configuration options

- user  
  AtCoder username  
  If omitted, you are prompted to enter it on the first login.  
  AtCoderのユーザ名  
  省略した場合、初回のログイン時に入力を求められます

- password  
  AtCoder password  
  If omitted, you are prompted to enter it on the first login.  
  AtCoderのパスワード  
  省略した場合、初回のログイン時に入力を求められます

- generators  
  List of source generator class names  
  In default, ```RubyBuiltin``` and ```CxxBuiltin``` are available.  
  For those other than above, it is available if the corresponding plugin is installed(?).  
  ソーススケルトンを生成するジェネレータのクラス名（リスト形式）  
  既定の状態では「RubyBuiltin」と「CxxBuiltin」が利用でき、  
  上記以外については、対応するプラグインがインストールされていれば利用できます（？）  

  For example, if ```RubyAlt``` is specified as generator name,  
  it is available if the following plugin is installed:
    |                 |                                                   |
    |-----------------|---------------------------------------------------|
    |Gem Name         |```at_coder_friends-generator-ruby_alt```          |
    |Require Statement|```require 'at_coder_friends/generator/ruby_alt'```|
    |Main Class Name  |```AtCoderFriends::Generator::RubyAlt```           |

- generator_settings
  - _(generator name)_  
    Settings for each generator  
    For details, see the manual of each generator.  
    [Settings for built-in generators](#builtin-generator-settings)  
    ジェネレータ毎の設定  
    詳細は各ジェネレータのマニュアルを参照してください  
    [組込ジェネレータの設定](#builtin-generator-settings)

- ext_settings  
  Extension specific settings  
  拡張子ごとの設定

  - _'ext'_  
    Target extension name  
    対象となる拡張子

    - submit_lang  
      Language ID of submission language  
      提出言語の言語ID

    - test_cmd  
      Execution command for test  
      If not set, the test will run using AtCoder "Custom Test" page.  
      テストで使用する実行コマンドの設定  
      未設定の場合、テストはAtCoderの「コードテスト」ページを使用して行われます

      - default  
        Default execution command  
        デフォルトの実行コマンド

      - wndows  
        Execution command for Windows(optional)  
        Windows専用実行コマンド(あれば設定)

      - macosx  
        Execution command for MacOS(optional)  
        MacOS専用実行コマンド(あれば設定)

      - linux  
        Execution command for Linux(optional)  
        Linux専用実行コマンド(あれば設定)

<a id="builtin-generator-settings"></a>
### Settings for RubyBuiltin generator
| Setting | Description | Default |
|---------|-------------|---------|
|default_template|Source template file path|[/templates/ruby_builtin_default.rb](/templates/ruby_builtin_default.rb)|
|interactive_template|Source template file path for interactive problems|[/templates/ruby_builtin_interactive.rb](/templates/ruby_builtin_interactive.rb)|

### Settings for CxxBuiltin generator
| Setting | Description | Default |
|---------|-------------|---------|
|default_template|Source template file path|[/templates/cxx_builtin_default.cxx](/templates/cxx_builtin_default.cxx)|
|interactive_template|Source template file path for interactive problems|[/templates/cxx_builtin_interactive.cxx](/templates/cxx_builtin_interactive.cxx)|

### Language ID list (2019/09/16)

| Language ID | Description |
|-------------|-------------|
|3003|C++14 (GCC 5.4.1)|
|3001|Bash (GNU bash v4.3.11)|
|3002|C (GCC 5.4.1)|
|3004|C (Clang 3.8.0)|
|3005|C++14 (Clang 3.8.0)|
|3006|C# (Mono 4.6.2.0)|
|3007|Clojure (1.8.0)|
|3008|Common Lisp (SBCL 1.1.14)|
|3009|D (DMD64 v2.070.1)|
|3010|D (LDC 0.17.0)|
|3011|D (GDC 4.9.4)|
|3012|Fortran (gfortran v4.8.4)|
|3013|Go (1.6)|
|3014|Haskell (GHC 7.10.3)|
|3015|Java7 (OpenJDK 1.7.0)|
|3016|Java8 (OpenJDK 1.8.0)|
|3017|JavaScript (node.js v5.12)|
|3018|OCaml (4.02.3)|
|3019|Pascal (FPC 2.6.2)|
|3020|Perl (v5.18.2)|
|3021|PHP (5.6.30)|
|3022|Python2 (2.7.6)|
|3023|Python3 (3.4.3)|
|3024|Ruby (2.3.3)|
|3025|Scala (2.11.7)|
|3026|Scheme (Gauche 0.9.3.3)|
|3027|Text (cat)|
|3028|Visual Basic (Mono 4.0.1)|
|3029|C++ (GCC 5.4.1)|
|3030|C++ (Clang 3.8.0)|
|3501|Objective-C (GCC 5.3.0)|
|3502|Objective-C (Clang3.8.0)|
|3503|Swift (swift-2.2-RELEASE)|
|3504|Rust (1.15.1)|
|3505|Sed (GNU sed 4.2.2)|
|3506|Awk (mawk 1.3.3)|
|3507|Brainfuck (bf 20041219)|
|3508|Standard ML (MLton 20100608)|
|3509|PyPy2 (5.6.0)|
|3510|PyPy3 (2.4.0)|
|3511|Crystal (0.20.5)|
|3512|F# (Mono 4.0)|
|3513|Unlambda (0.1.3)|
|3514|Lua (5.3.2)|
|3515|LuaJIT (2.0.4)|
|3516|MoonScript (0.5.0)|
|3517|Ceylon (1.2.1)|
|3518|Julia (0.5.0)|
|3519|Octave (4.0.2)|
|3520|Nim (0.13.0)|
|3521|TypeScript (2.1.6)|
|3522|Perl6 (rakudo-star 2016.01)|
|3523|Kotlin (1.0.0)|
|3524|PHP7 (7.0.15)|
|3525|COBOL - Fixed (OpenCOBOL 1.1.0)|
|3526|COBOL - Free (OpenCOBOL 1.1.0)|

### Variables in test_cmd string

The following variables in test_cmd string  
is substituted with the path information of the target file  
during execution.

test_cmd 文字列中の以下の変数には、  
実行時に対象ファイルのパス情報が展開されます。

| Variable | Descripton                                                     |
|----------|----------------------------------------------------------------|
|{dir}     |the directory name of the file<br>ファイルの置かれているディレクトリ名|
|{base}    |the file name excluding the extension<br>拡張子を除いたファイル名   |

## Examples of overwriting settings

- Use only Ruby source generator  
  Rubyのソースジェネレータのみ使用
  ```YAML
  generators:
    - RubyBuiltin
  ```
- Do not use source generator  
  ソースジェネレータを使用しない
  ```YAML
  generators: ~
  ```

- Test .py with local Python  
  .pyをローカル環境のPythonでテスト
  ```YAML
  ext_settings:
    'py':
      test_cmd:
        default: 'python "{dir}/{base}.py"'
  ```

- Test .rb with "Custom Test" page  
  .rb を「コードテスト」ページでテスト
  ```YAML
  ext_settings:
    'rb':
      test_cmd: ~
  ```

- Add .pl6(Perl6) settings  
  .pl6(Perl6)の設定を追加
  ```YAML
  ext_settings:
    'pl6':
      submit_lang: '3522' # Perl6
  ```

- Change submission language of .cxx to C++14(Clang)  
  .cxxの提出言語をC++14(Clang)に変更
  ```YAML
  ext_settings:
    'cxx':
      submit_lang: '3005' # C++14(Clang)
  ```
