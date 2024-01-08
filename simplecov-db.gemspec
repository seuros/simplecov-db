# frozen_string_literal: true

require_relative 'lib/simplecov/db/version'

Gem::Specification.new do |spec|
  spec.name = 'simplecov-db'
  spec.version = SimpleCov::DB::VERSION
  spec.authors = ['Abdelkader Boudih']
  spec.email = ['terminale@gmail.com']

  spec.summary = 'SimpleCov DB is formatter for SimpleCov to save coverage data to a database.'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/seuros/simplecov-db'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/seuros/simplecov-db'
  spec.metadata['changelog_uri'] = 'https://github.com/seuros/simplecov-db/blob/master/CHANGELOG.md'

  spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) }

  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'simplecov'
  spec.add_dependency 'sqlite3'
end
