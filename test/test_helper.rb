# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"
require 'simplecov-db'
SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::DBFormatter,
                                                                 SimpleCov::Formatter::HTMLFormatter
                                                               ])

