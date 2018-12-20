# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'at_coder_friends/version'

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

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'mechanize', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
