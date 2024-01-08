# frozen_string_literal: true

require 'test_helper'

module SimpleCov
  class TestDB < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil SimpleCov::DB::VERSION
    end
  end
end
