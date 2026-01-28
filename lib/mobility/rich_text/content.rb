# frozen_string_literal: true

module Mobility
  module RichText
    # Public: Wraps an HTML string with ActionText::Content functionality.
    #
    # This class provides a consistent interface for rich text content,
    # delegating most methods to the underlying ActionText::Content while
    # adding Mobility-specific functionality. It allows translated content
    # to be treated as rich text without requiring separate ActionText records.
    #
    # Examples
    #
    #   wrapper = Mobility::RichText::Content.new("<p>Hello <strong>world</strong></p>")
    #   wrapper.to_plain_text
    #   # => "Hello world"
    #
    #   wrapper.to_html
    #   # => "<p>Hello <strong>world</strong></p>"
    #
    #   wrapper.blank?
    #   # => false
    #
    class Content
      # Public: Returns the underlying ActionText::Content instance.
      attr_reader :content

      # Public: Creates a new Content instance.
      #
      # html - The String HTML content to wrap. Will be converted to String
      #        if another type is provided. Nil values become empty strings.
      #
      # Examples
      #
      #   Content.new("<p>Hello</p>")
      #   # => #<Mobility::RichText::Content ...>
      #
      #   Content.new(nil)
      #   # => #<Mobility::RichText::Content @content="">
      #
      # Returns a new Content instance.
      def initialize(html)
        @html = html.to_s
        @content = ActionText::Content.new(@html)
      end

      # Public: Returns the rendered HTML content as a String.
      #
      # This method renders the content. In a Rails environment with
      # ActionController available, it renders attachments. In standalone
      # contexts, it returns the HTML directly.
      #
      # Examples
      #
      #   wrapper = Content.new("<p>Hello</p>")
      #   wrapper.to_s
      #   # => "<p>Hello</p>"
      #
      # Returns the String HTML content.
      def to_s
        # In standalone contexts, to_s requires ActionController which may not
        # be available. Fall back to to_html in those cases.
        @content.to_s
      rescue NameError
        @content.to_html
      end

      # Public: Returns the HTML content as a String.
      #
      # Unlike to_s, this returns the raw HTML without rendering attachments.
      #
      # Examples
      #
      #   wrapper = Content.new("<p>Hello</p>")
      #   wrapper.to_html
      #   # => "<p>Hello</p>"
      #
      # Returns the String HTML content.
      def to_html
        @content.to_html
      end

      # Public: Returns the content with HTML tags stripped.
      #
      # Useful for displaying a plain text preview or for indexing.
      #
      # Examples
      #
      #   wrapper = Content.new("<p>Hello <strong>world</strong></p>")
      #   wrapper.to_plain_text
      #   # => "Hello world"
      #
      # Returns the String plain text content.
      def to_plain_text
        @content.to_plain_text
      end

      # Public: Checks if the content is blank.
      #
      # Content is considered blank if it is empty, contains only whitespace,
      # or contains only empty HTML tags.
      #
      # Examples
      #
      #   Content.new("").blank?
      #   # => true
      #
      #   Content.new("<p>   </p>").blank?
      #   # => true
      #
      #   Content.new("<p>Hello</p>").blank?
      #   # => false
      #
      # Returns true if the content is blank, false otherwise.
      def blank?
        @content.blank?
      end

      # Public: Checks if the content is present (not blank).
      #
      # Examples
      #
      #   Content.new("<p>Hello</p>").present?
      #   # => true
      #
      #   Content.new("").present?
      #   # => false
      #
      # Returns true if the content is present, false otherwise.
      def present?
        !blank?
      end

      # Public: Returns the underlying ActionText::Content instance.
      #
      # Useful when you need direct access to ActionText::Content methods
      # that are not delegated.
      #
      # Examples
      #
      #   wrapper = Content.new("<p>Hello</p>")
      #   wrapper.to_action_text_content
      #   # => #<ActionText::Content ...>
      #
      # Returns the ActionText::Content instance.
      def to_action_text_content
        @content
      end

      # Public: Compares this wrapper with another object for equality.
      #
      # other - The Object to compare against. Can be:
      #         Content - compares HTML content
      #         ActionText::Content - compares HTML content
      #         String - compares against HTML string
      #
      # Examples
      #
      #   wrapper = Content.new("<p>Hello</p>")
      #   wrapper == Content.new("<p>Hello</p>")
      #   # => true
      #
      #   wrapper == "<p>Hello</p>"
      #   # => true
      #
      #   wrapper == ActionText::Content.new("<p>Hello</p>")
      #   # => true
      #
      # Returns true if the objects are considered equal, false otherwise.
      def ==(other)
        case other
        when Content, ActionText::Content
          to_html == other.to_html
        when String
          to_html == other
        else
          false
        end
      end
    end
  end
end
