# frozen_string_literal: true

require_relative 'lib/modrinth/gem_version'

Gem::Specification.new do |spec|
  spec.name = 'modrinth'
  spec.version = Modrinth::VERSION
  spec.authors = ['ForeverZer0']
  spec.email = ['efreed09@gmail.com']

  spec.summary = 'Ruby interface for the Modrinth API, an open-source Minecraft modding platform.'
  spec.description = 'Ruby interface for the Modrinth API, an open-source Minecraft modding platform.'
  spec.homepage = 'https://github.com/ForeverZer0/modrinth'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ForeverZer0/modrinth'
  spec.metadata['changelog_uri'] = 'https://github.com/ForeverZer0/modrinth/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'sord', '~> 5.0'
  spec.add_development_dependency 'yard', '~> 0.9'

end
