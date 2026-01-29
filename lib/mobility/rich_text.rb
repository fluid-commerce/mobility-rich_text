# frozen_string_literal: true

require_relative "rich_text/version"
require_relative "rich_text/content"
require_relative "rich_text/plugins/rich_text"

module Mobility
  # Public: A Mobility plugin that wraps translated string values with
  # ActionText::Content, providing rich text editing capabilities for
  # internationalized content.
  #
  # This gem provides a plugin architecture that works with ANY Mobility
  # backend (KeyValue, Table, JSON, JSONB, Hstore) without requiring
  # additional database tables or schema changes.
  #
  # Unlike mobility-actiontext which stores rich text in separate
  # ActionText::RichText records, this plugin keeps translations in your
  # existing backend while providing full ActionText features.
  #
  # Examples
  #
  #   class Article < ApplicationRecord
  #     extend Mobility
  #
  #     # Enable rich_text plugin for specific attribute
  #     translates :title, backend: :key_value  # No rich text
  #     translates :content, backend: :key_value, rich_text: true  # With rich text
  #   end
  #
  #   article = Article.new
  #   article.content = "<p>Hello <strong>world</strong></p>"
  #   article.content.to_plain_text
  #   # => "Hello world"
  #
  module RichText
    # Public: Base error class for all mobility-rich_text errors.
    #
    # All custom exceptions raised by this gem inherit from this class,
    # allowing rescue blocks to catch all gem-specific errors.
    #
    # Examples
    #
    #   begin
    #     # mobility-rich_text operations
    #   rescue Mobility::RichText::Error => e
    #     # Handle any mobility-rich_text error
    #   end
    #
    class Error < StandardError; end
  end
end
