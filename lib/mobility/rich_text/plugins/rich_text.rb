# frozen_string_literal: true

require "mobility"

module Mobility
  module Plugins # rubocop:disable Style/Documentation
    # Public: A Mobility plugin that wraps translated string values with
    # ActionText::Content, providing rich text editing capabilities.
    #
    # This plugin intercepts read and write operations on translated attributes,
    # automatically wrapping string values from any Mobility backend with
    # Mobility::RichText::Content on read, and converting rich text objects
    # back to HTML strings on write.
    #
    # The plugin is disabled by default and must be explicitly enabled per
    # attribute using the `rich_text: true` option.
    #
    # Examples
    #
    #   class Article < ApplicationRecord
    #     extend Mobility
    #
    #     # Enable rich_text plugin for content attribute
    #     translates :content, backend: :key_value, rich_text: true
    #
    #     # Title remains a plain string
    #     translates :title, backend: :key_value
    #   end
    #
    #   article = Article.new
    #   article.content = "<p>Hello <strong>world</strong></p>"
    #   article.content.to_plain_text
    #   # => "Hello world"
    #
    #   # Bypass rich text wrapping
    #   article.content(rich_text: false)
    #   # => "<p>Hello <strong>world</strong></p>"
    #
    module RichText
      extend Mobility::Plugin

      # Plugin is disabled by default
      default false

      # Internal: Hook called when the plugin is included in a backend class.
      #
      # Includes BackendMethods in the backend class when rich_text option
      # is enabled for the attribute.
      included_hook do |klass|
        klass.include(BackendMethods) if options[:rich_text]
      end

      # Public: Methods mixed into backend classes when rich_text is enabled.
      #
      # These methods override the standard read and write behavior to
      # automatically wrap and unwrap ActionText::Content objects.
      #
      module BackendMethods
        # Public: Reads the translated value and wraps it with Content.
        #
        # locale  - The Symbol locale to read.
        # options - Hash of options:
        #           :rich_text - Set to false to bypass wrapping and
        #                        return the raw string value.
        #
        # Examples
        #
        #   backend.read(:en)
        #   # => #<Mobility::RichText::Content ...>
        #
        #   backend.read(:en, rich_text: false)
        #   # => "<p>Raw HTML string</p>"
        #
        # Returns Mobility::RichText::Content wrapping the value, or nil if
        # the value is nil. Returns the raw String if rich_text: false.
        def read(locale, **options)
          # Allow bypassing rich text wrapping
          return super if options[:rich_text] == false

          value = super
          return nil if value.nil?

          Mobility::RichText::Content.new(value)
        end

        # Public: Writes a value after normalizing it to an HTML string.
        #
        # locale  - The Symbol locale to write.
        # value   - The value to write. Accepts:
        #           String - stored as-is
        #           Mobility::RichText::Content - extracts HTML via to_html
        #           ActionText::Content - extracts HTML via to_html
        #           ActionText::RichText - extracts HTML via body.to_html
        #           nil - stored as nil
        #           Other - converted via to_s
        # options - Hash of additional options passed to the backend.
        #
        # Examples
        #
        #   backend.write(:en, "<p>Hello</p>")
        #   backend.write(:en, ActionText::Content.new("<p>Hello</p>"))
        #   backend.write(:en, content_wrapper)
        #
        # Returns the result of the underlying backend write operation.
        def write(locale, value, **options) # rubocop:disable Style/ArgumentsForwarding
          normalized = normalize_value(value)
          super(locale, normalized, **options) # rubocop:disable Style/ArgumentsForwarding
        end

        private

        # Internal: Normalizes various input types to an HTML string.
        #
        # value - The value to normalize. Accepts String, Content,
        #         ActionText::Content, ActionText::RichText, or nil.
        #
        # Returns the String HTML representation, or nil if value was nil.
        def normalize_value(value)
          case value
          when nil then nil
          when String then value
          when Mobility::RichText::Content, ActionText::Content then value.to_html
          when action_text_rich_text_class then value.body.to_html
          else value.to_s
          end
        end

        # Internal: Returns ActionText::RichText class if defined, nil otherwise.
        #
        # Returns Class or nil.
        def action_text_rich_text_class
          defined?(ActionText::RichText) ? ActionText::RichText : nil
        end
      end
    end

    register_plugin(:rich_text, RichText)
  end
end
