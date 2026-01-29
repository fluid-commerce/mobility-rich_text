# frozen_string_literal: true

require "test_helper"
require "mobility"

module Mobility
  module Plugins
    class RichTextTest < Minitest::Test
      # Mock backend class for testing plugin behavior
      class MockBackend
        attr_accessor :stored_value

        def initialize
          @stored_value = nil
        end

        def read(_locale, **_options)
          @stored_value
        end

        def write(_locale, value, **_options)
          @stored_value = value
        end
      end

      # Backend with RichText plugin methods included
      class RichTextBackend < MockBackend
        include Mobility::Plugins::RichText::BackendMethods
      end

      def setup
        @backend = RichTextBackend.new
      end

      # Plugin Registration Tests

      def test_plugin_is_registered_with_mobility
        plugin = Mobility::Plugins.load_plugin(:rich_text)

        assert_equal Mobility::Plugins::RichText, plugin,
                     "Plugin should be registered with Mobility"
      end

      def test_plugin_module_exists
        assert defined?(Mobility::Plugins::RichText),
               "Mobility::Plugins::RichText module should exist"
      end

      def test_backend_methods_module_exists
        assert defined?(Mobility::Plugins::RichText::BackendMethods),
               "BackendMethods module should exist"
      end

      # Read Tests

      def test_read_returns_content_when_value_present
        @backend.stored_value = "<p>Hello</p>"

        result = @backend.read(:en)

        assert_instance_of Mobility::RichText::Content, result
        assert_equal "<p>Hello</p>", result.to_html
      end

      def test_read_returns_nil_when_value_is_nil
        @backend.stored_value = nil

        result = @backend.read(:en)

        assert_nil result
      end

      def test_read_returns_empty_content_for_empty_string
        @backend.stored_value = ""

        result = @backend.read(:en)

        assert_instance_of Mobility::RichText::Content, result
        assert_equal "", result.to_html
        assert result.blank?
      end

      def test_read_bypasses_wrapping_when_rich_text_false
        @backend.stored_value = "<p>Hello</p>"

        result = @backend.read(:en, rich_text: false)

        assert_equal "<p>Hello</p>", result
        refute_instance_of Mobility::RichText::Content, result
      end

      # Write Tests

      def test_write_accepts_string
        @backend.write(:en, "<p>Hello</p>")

        assert_equal "<p>Hello</p>", @backend.stored_value
      end

      def test_write_accepts_nil
        @backend.write(:en, nil)

        assert_nil @backend.stored_value
      end

      def test_write_accepts_content_and_extracts_html
        content = Mobility::RichText::Content.new("<p>Hello</p>")

        @backend.write(:en, content)

        assert_equal "<p>Hello</p>", @backend.stored_value
      end

      def test_write_accepts_action_text_content_and_extracts_html
        action_text_content = ActionText::Content.new("<p>Hello</p>")

        @backend.write(:en, action_text_content)

        assert_equal "<p>Hello</p>", @backend.stored_value
      end

      def test_write_converts_other_types_to_string
        @backend.write(:en, 12_345)

        assert_equal "12345", @backend.stored_value
      end

      # Round-trip Tests

      def test_round_trip_with_string
        @backend.write(:en, "<p>Hello <strong>world</strong></p>")
        result = @backend.read(:en)

        assert_instance_of Mobility::RichText::Content, result
        assert_equal "<p>Hello <strong>world</strong></p>", result.to_html
        assert_equal "Hello world", result.to_plain_text
      end

      def test_round_trip_with_content
        original = Mobility::RichText::Content.new("<p>Test</p>")

        @backend.write(:en, original)
        result = @backend.read(:en)

        assert_instance_of Mobility::RichText::Content, result
        assert_equal original, result
      end

      def test_round_trip_preserves_html_structure
        html = '<div class="content"><p>Paragraph 1</p><p>Paragraph 2</p></div>'

        @backend.write(:en, html)
        result = @backend.read(:en)

        assert_equal html, result.to_html
      end

      # Multiple Locales Tests

      def test_handles_multiple_locales
        backend_en = RichTextBackend.new
        backend_es = RichTextBackend.new

        backend_en.write(:en, "<p>Hello</p>")
        backend_es.write(:es, "<p>Hola</p>")

        result_en = backend_en.read(:en)
        result_es = backend_es.read(:es)

        assert_equal "<p>Hello</p>", result_en.to_html
        assert_equal "<p>Hola</p>", result_es.to_html
      end
    end
  end
end
