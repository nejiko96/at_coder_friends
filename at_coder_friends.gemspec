# frozen_string_literal: true

require_relative 'lib/at_coder_friends/version'

Gem::Specification.new do |spec|
  spec.name          = 'at_coder_friends'
  spec.version       = AtCoderFriends::VERSION
  spec.authors       = ['nejiko96']
  spec.email         = ['nejiko2006@gmail.com']

  spec.summary       = 'AtCoder support tool'
  spec.description   = <<-DESCRIPTION
    AtCoder support tool
    - generate source template
    - generate test data from sample input/output
    - run tests
    - submit code
  DESCRIPTION
  spec.homepage      = 'https://github.com/nejiko96/at_coder_friends'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|tasks)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'rubygems_mfa_required' => 'true'
  }

  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'launchy', '>= 2.4.3'
  spec.add_dependency 'mechanize', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.10', '< 0.18'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
