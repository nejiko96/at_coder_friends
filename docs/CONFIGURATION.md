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
  'awk': # Awk (mawk)
    submit_lang:
      - '4009'
      - '3506'
  'bf': # Brainfuck
    submit_lang:
      - '4062'
      - '3507'
  'c': # C (GCC)
    submit_lang:
      - '4001'
      - '3002'
    test_cmd:
      default: '"{dir}/{base}"'
      windows: '"{dir}/{base}.exe"'
  'cbl': # COBOL - Free
    submit_lang:
      - '4061'
      - '3526'
  'clj': # Clojure
    submit_lang:
      - '4013'
      - '3007'
  'cr': # Crystal
    submit_lang:
      - '4014'
      - '3511'
  'cs': # C# (Mono-mcs)
    submit_lang:
      - '4011'
      - '3006'
    test_cmd:
      default: 'mono "{dir}/{base}.exe"'
      windows: '"{dir}/{base}.exe"'
  'cxx': # C++ (GCC)
    submit_lang:
      - '4003'
      - '3003'
    test_cmd:
      default: '"{dir}/{base}"'
      windows: '"{dir}/{base}.exe"'
  'd': # D (DMD64)
    submit_lang:
      - '4015'
      - '3009'
  'dart': # Dart
    submit_lang: '4018'
  'f90': # Fortran (gfortran)
    submit_lang:
      - '4025'
      - '3012'
  'fs': # F# (Mono)
    submit_lang:
      - '4023'
      - '3512'
  'go': # Go
    submit_lang:
      - '4026'
      - '3013'
  'hs': # Haskell (GHC)
    submit_lang:
      - '4027'
      - '3014'
  'java': # Java (OpenJDK)
    submit_lang:
      - '4005'
      - '3016'
    test_cmd:
      default: 'java -cp "{dir}" Main'
  'jl': # Julia
    submit_lang:
      - '4031'
      - '3518'
  'js': # JavaScript (node.js)
    submit_lang:
      - '4030'
      - '3017'
  'kt': # Kotlin
    submit_lang:
      - '4032'
      - '3523'
  'lisp': # Common Lisp
    submit_lang:
      - '4038'
      - '3008'
  'lua': # LuaJIT
    submit_lang:
      - '4034'
      - '3515'
  'm': # Octave
    submit_lang:
      - '4040'
      - '3519'
  'ml': # OCaml
    submit_lang:
      - '4039'
      - '3018'
  'nim': # Nim
    submit_lang:
      - '4036'
      - '3520'
  'pas': # Pascal (FPC)
    submit_lang:
      - '4041'
      - '3019'
  'php': # PHP7
    submit_lang:
      - '4044'
      - '3524'
  'pl': # Perl
    submit_lang:
      - '4042'
      - '3020'
  'py': # Python3
    submit_lang:
      - '4006'
      - '3023'
  'rb': # Ruby
    submit_lang:
      - '4049'
      - '3024'
    test_cmd:
      default: 'ruby "{dir}/{base}.rb"'
  'rs': # Rust
    submit_lang:
      - '4050'
      - '3504'
  'scala': # Scala
    submit_lang:
      - '4051'
      - '3025'
  'scm': # Scheme (Gauche)
    submit_lang:
      - '4053'
      - '3026'
  'sed': # Sed (GNU sed)
    submit_lang:
      - '4066'
      - '3505'
  'sh': # Bash (GNU bash)
    submit_lang:
      - '4007'
      - '3001'
  'swift': # Swift
    submit_lang:
      - '4055'
      - '3503'
  'ts': # TypeScript
    submit_lang:
      - '4057'
      - '3521'
  'txt': # Text (cat)
    submit_lang:
      - '4056'
      - '3027'
  'vb': # Visual Basic (Mono)
    submit_lang:
      - '4058'
      - '3028'
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
  A list of class names for source code generators.  
  By default, ```RubyBuiltin```, ```CxxBuiltin```, ```CBuiltin``` and ```AnyBuiltin``` are available.  
  Other generators can be used if the corresponding plugin has been installed.  
  ソースジェネレータのクラス名（リスト形式）  
  既定の状態では「RubyBuiltin」「CxxBuiltin」「CBuiltin」「AnyBuiltin」が利用でき、  
  その他のジェネレータが指定された場合は、対応するプラグインがインストールされていれば  
  利用できます  

  For example, if ```RubyAlt``` is specified as generator name,  
  following plugin will be used:
  
    |                 |                                                   |
    |-----------------|---------------------------------------------------|
    |Gem Name         |```at_coder_friends-generator-ruby_alt```          |
    |Require Statement|```require 'at_coder_friends/generator/ruby_alt'```|
    |Main Class Name  |```AtCoderFriends::Generator::RubyAlt```           |
  
  [search generator in GitHub](https://github.com/search?q=at_coder_friends-generator)

　 The same generator can be used multiple times
   by adding suffix starts with underscore to the class name,
   such as "AnyBuiltin_1" or "AnyBuiltin_JS".

  「AnyBuiltin_1」「AnyBuiltin_JS」のように
  クラス名にアンダースコアで始まるサフィックスを付加すると
  同じジェネレータを設定を変えて複数回指定することができます

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
| Setting | Description  | Default |
|---------|--------------|---------|
|file_ext |File extension|rb       |
|default_template|Template file path|[/templates/ruby_builtin.rb.erb](/templates/ruby_builtin.rb.erb)|

### Settings for CxxBuiltin generator
| Setting | Description  | Default |
|---------|--------------|---------|
|file_ext |File extension|cxx      |
|default_template|Template file path|[/templates/cxx_builtin.cxx.erb](/templates/cxx_builtin.cxx.erb)|

### Settings for CBuiltin generator
| Setting | Description  | Default |
|---------|--------------|---------|
|file_ext |File extension|c        |
|default_template|Template file path|[/templates/c_builtin.c.erb](/templates/c_builtin.c.erb)|

### Settings for AnyBuiltin generator
| Setting | Description  | Default |
|---------|--------------|---------|
|file_ext |File extension|txt      |
|default_template|Template file path|[/templates/any_builtin.txt.erb](/templates/any_builtin.txt.erb)|

### Language ID list (2020/06/21)

| Language ID | Description |
|-------------|-------------|
|4001|C (GCC 9.2.1)|
|4002|C (Clang 10.0.0)|
|4003|C++ (GCC 9.2.1)|
|4004|C++ (Clang 10.0.0)|
|4005|Java (OpenJDK 11.0.6)|
|4006|Python (3.8.2)|
|4007|Bash (5.0.11)|
|4008|bc (1.07.1)|
|4009|Awk (GNU Awk 4.1.4)|
|4010|C# (.NET Core 3.1.201)|
|4011|C# (Mono-mcs 6.8.0.105)|
|4012|C# (Mono-csc 3.5.0)|
|4013|Clojure (1.10.1.536)|
|4014|Crystal (0.33.0)|
|4015|D (DMD 2.091.0)|
|4016|D (GDC 9.2.1)|
|4017|D (LDC 1.20.1)|
|4018|Dart (2.7.2)|
|4019|dc (1.4.1)|
|4020|Erlang (22.3)|
|4021|Elixir (1.10.2)|
|4022|F# (.NET Core 3.1.201)|
|4023|F# (Mono 10.2.3)|
|4024|Forth (gforth 0.7.3)|
|4025|Fortran(GNU Fortran 9.2.1)|
|4026|Go (1.14.1)|
|4027|Haskell (GHC 8.8.3)|
|4028|Haxe (4.0.3); js|
|4029|Haxe (4.0.3); Java|
|4030|JavaScript (Node.js 12.16.1)|
|4031|Julia (1.4.0)|
|4032|Kotlin (1.3.71)|
|4033|Lua (Lua 5.3.5)|
|4034|Lua (LuaJIT 2.1.0)|
|4035|Dash (0.5.8)|
|4036|Nim (1.0.6)|
|4037|Objective-C (Clang 10.0.0)|
|4038|Common Lisp (SBCL 2.0.3)|
|4039|OCaml (4.10.0)|
|4040|Octave (5.2.0)|
|4041|Pascal (FPC 3.0.4)|
|4042|Perl (5.26.1)|
|4043|Raku (Rakudo 2020.02.1)|
|4044|PHP (7.4.4)|
|4045|Prolog (SWI-Prolog 8.0.3)|
|4046|PyPy2 (7.3.0)|
|4047|PyPy3 (7.3.0)|
|4048|Racket (7.6)|
|4049|Ruby (2.7.1)|
|4050|Rust (1.42.0)|
|4051|Scala (2.13.1)|
|4052|Java (OpenJDK 1.8.0)|
|4053|Scheme (Gauche 0.9.9)|
|4054|Standard ML (MLton 20130715)|
|4055|Swift (5.2.1)|
|4056|Text (cat 8.28)|
|4057|TypeScript (3.8)|
|4058|Visual Basic (.NET Core 3.1.101)|
|4059|Zsh (5.4.2)|
|4060|COBOL - Fixed (OpenCOBOL 1.1.0)|
|4061|COBOL - Free (OpenCOBOL 1.1.0)|
|4062|Brainfuck (bf 20041219)|
|4063|Ada2012 (GNAT 9.2.1)|
|4064|Unlambda (2.0.0)|
|4065|Cython (0.29.16)|
|4066|Sed (4.4)|
|4067|Vim (8.2.0460)|


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
- change C++ source template  
  C++のソース雛型を変更
  ```YAML
  generator_settings:
    CxxBuiltin:
      default_template: /path/to/template
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

- Add .raku(Raku) settings  
  .raku(Raku)の設定を追加
  ```YAML
  ext_settings:
    'raku':
      submit_lang: '4043' # Raku
  ```

- Change submission language of .cxx to C++(Clang)  
  .cxxの提出言語をC++(Clang)に変更
  ```YAML
  ext_settings:
    'cxx':
      submit_lang: '4004' # C++(Clang)
  ```
