[![Gem Version](https://badge.fury.io/rb/at_coder_friends.svg)](https://badge.fury.io/rb/at_coder_friends)
[![Ruby](https://github.com/nejiko96/at_coder_friends/actions/workflows/ruby.yml/badge.svg)](https://github.com/nejiko96/at_coder_friends/actions/workflows/ruby.yml)
<!-- [![Build Status](https://travis-ci.org/nejiko96/at_coder_friends.svg?branch=master)](https://travis-ci.org/nejiko96/at_coder_friends) -->
[![CodeQL](https://github.com/nejiko96/at_coder_friends/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/nejiko96/at_coder_friends/actions/workflows/codeql-analysis.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/dcd1ce08d11703be2f00/maintainability)](https://codeclimate.com/github/nejiko96/at_coder_friends/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/dcd1ce08d11703be2f00/test_coverage)](https://codeclimate.com/github/nejiko96/at_coder_friends/test_coverage)

# AtCoderFriends

## Description

AtCoderFriends automates tasks about [AtCoder](https://atcoder.jp/) programming contest such as:

- Download example input/output
- Generate source skeleton
- Run test cases
- Submit code

## Dependencies

- Ruby 2.5 or newer
- [Mechanize](https://github.com/sparklemotion/mechanize)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'at_coder_friends'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install at_coder_friends

## Usage

### Setup

```
at_coder_friends setup         /path/to/contest
```

Creates contest folder, and generates example data and source skeletons into the folder.

### Open contest page

```
at_coder_friends open-contest  /path/to/contest/source_file
```

Opens the contet page which the contest folder linked to.

### Run first test case

```
at_coder_friends test-one      /path/to/contest/source_file
```

### Run all test cases

```
at_coder_friends test-all      /path/to/contest/source_file
```

### Submit code

```
at_coder_friends submit        /path/to/contest/source_file
```

### Submit code automatically if all tests passed

```
at_coder_friends check-and-go  /path/to/contest/source_file
```

### Naming convention

- Contest folder name will be used in the contest site URL.
  For example, if ```arc001``` folder is specified, AtCoderFriends will use  ```https://atcoder.jp/contests/arc001/```.
- Source file should be named ```[problem ID].[language specific extension]```(e.g. ```A.rb```),
  in order to let AtCoderFriends find test cases or fill the submission form.
- Suffixes (start with underscore) may be added to the file name (e.g. ```A_v2.rb```),
  so that you can try multiple codes for one problem.

## Notes

- Compilation is not supported.
- Source generator supports Ruby and C++ in default, and can be added by plugin.
- Test runner and code submission are supported in 36 languages.


## Configuration

See [CONFIGURATION.md](docs/CONFIGURATION.md) for details.

## For Sublime Text user

It is convenient to use AtCoderFriends from Sublime Text plugin.

- [sublime_at_coder_friends](https://github.com/nejiko96/sublime_at_coder_friends)

## For Visual Studio Code user

- Run **Configure Tasks** from the global Terminal menu.
- Select the **Create tasks.json file from template** entry.
- Select **Others** from the list.
- Add following settings to ```tasks.json```.

```JSON
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AtCoderFriends:New Contest",
      "type": "shell",
      "command": "at_coder_friends",
      "args": [
        "setup",
        "${input:contestName}"
      ],
      "problemMatcher": [],
      "group": "none"
    },
    {
      "label": "AtCoderFriends:Test One",
      "type": "shell",
      "command": "at_coder_friends",
      "args": [
        "test-one",
        "${file}"
      ],
      "problemMatcher": [],
      "group": "none"
    },
    {
      "label": "AtCoderFriends:Test All",
      "type": "shell",
      "command": "at_coder_friends",
      "args": [
        "test-all",
        "${file}"
      ],
      "problemMatcher": [],
      "group": "none"
    },
    {
      "label": "AtCoderFriends:Submit",
      "type": "shell",
      "command": "at_coder_friends",
      "args": [
        "submit",
        "${file}"
      ],
      "problemMatcher": [],
      "group": "none",
    },
    {
      "label": "AtCoderFriends:Check & Go",
      "type": "shell",
      "command": "at_coder_friends",
      "args": [
        "check-and-go",
        "${file}"
      ],
      "problemMatcher": [],
      "group": "none",
    },
    ...
  ],
  "inputs": [
    {
      "id": "contestName",
      "type": "promptString",
      "default": "",
      "description": "Contest Name"
    }
  ]
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

<!--
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
-->

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nejiko96/at_coder_friends. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AtCoderFriends project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nejiko96/at_coder_friends/blob/master/CODE_OF_CONDUCT.md).
