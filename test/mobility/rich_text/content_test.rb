# frozen_string_literal: true

require "test_helper"

module Mobility
  module RichText
    class ContentTest < Minitest::Test
      def test_initialize_accepts_html_string
        wrapper = Content.new("<p>Hello</p>")

        assert_instance_of Content, wrapper
      end

      def test_initialize_handles_nil
        wrapper = Content.new(nil)

        assert_instance_of Content, wrapper
        assert_equal "", wrapper.to_html
      end

      def test_initialize_handles_empty_string
        wrapper = Content.new("")

        assert_instance_of Content, wrapper
        assert_equal "", wrapper.to_html
      end

      def test_to_s_returns_rendered_html
        wrapper = Content.new("<p>Hello</p>")

        assert_equal "<p>Hello</p>", wrapper.to_s
      end

      def test_to_html_returns_html_string
        wrapper = Content.new("<p>Hello <strong>world</strong></p>")

        assert_equal "<p>Hello <strong>world</strong></p>", wrapper.to_html
      end

      def test_to_plain_text_strips_html_tags
        wrapper = Content.new("<p>Hello <strong>world</strong></p>")

        assert_equal "Hello world", wrapper.to_plain_text
      end

      def test_blank_returns_true_for_empty_content
        wrapper = Content.new("")

        assert wrapper.blank?
      end

      def test_blank_returns_true_for_nil_content
        wrapper = Content.new(nil)

        assert wrapper.blank?
      end

      def test_blank_returns_true_for_whitespace_only_text
        # ActionText considers whitespace-only text as blank
        wrapper = Content.new("   ")

        assert wrapper.blank?
      end

      def test_blank_returns_false_for_html_with_whitespace
        # HTML tags with whitespace content are not considered blank by ActionText
        # because they contain HTML structure
        wrapper = Content.new("<p>   </p>")

        refute wrapper.blank?
      end

      def test_blank_returns_false_for_content_with_text
        wrapper = Content.new("<p>Hello</p>")

        refute wrapper.blank?
      end

      def test_present_returns_true_for_content_with_text
        wrapper = Content.new("<p>Hello</p>")

        assert wrapper.present?
      end

      def test_present_returns_false_for_empty_content
        wrapper = Content.new("")

        refute wrapper.present?
      end

      def test_to_action_text_content_returns_action_text_content
        wrapper = Content.new("<p>Hello</p>")

        result = wrapper.to_action_text_content

        assert_instance_of ActionText::Content, result
        assert_equal "<p>Hello</p>", result.to_html
      end

      def test_equality_with_another_wrapper
        wrapper1 = Content.new("<p>Hello</p>")
        wrapper2 = Content.new("<p>Hello</p>")
        wrapper3 = Content.new("<p>Goodbye</p>")

        assert_equal wrapper1, wrapper2
        refute_equal wrapper1, wrapper3
      end

      def test_equality_with_action_text_content
        wrapper = Content.new("<p>Hello</p>")
        content = ActionText::Content.new("<p>Hello</p>")

        assert_equal wrapper, content
      end

      def test_equality_with_string
        wrapper = Content.new("<p>Hello</p>")

        assert_equal wrapper, "<p>Hello</p>"
        refute_equal wrapper, "<p>Goodbye</p>"
      end

      def test_equality_with_other_types_returns_false
        wrapper = Content.new("<p>Hello</p>")

        refute_equal wrapper, 123
        refute_equal wrapper, []
        refute_equal wrapper, {}
      end

      def test_content_reader_exposes_action_text_content
        wrapper = Content.new("<p>Hello</p>")

        # Access ActionText::Content methods via content reader
        assert_instance_of ActionText::Content, wrapper.content
        assert_equal [], wrapper.content.attachments.to_a
      end

      def test_content_reader_allows_link_extraction
        wrapper = Content.new('<p>Visit <a href="https://example.com">example</a></p>')

        assert_includes wrapper.content.links, "https://example.com"
      end
    end
  end
end
