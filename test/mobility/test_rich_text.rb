# frozen_string_literal: true

require "test_helper"

module Mobility
  class TestRichText < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Mobility::RichText::VERSION
    end
  end
end
