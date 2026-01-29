# frozen_string_literal: true

require_relative "integration_helper"

class KeyValueBackendTest < Minitest::Test
  def setup
    # Clean up translations between tests
    Mobility::Backends::ActiveRecord::KeyValue::StringTranslation.delete_all
    Mobility::Backends::ActiveRecord::KeyValue::TextTranslation.delete_all
    Article.delete_all
  end

  def test_read_returns_content_instance
    article = Article.create!
    article.content = "<p>Hello world</p>"
    article.save!

    article.reload
    result = article.content

    assert_instance_of Mobility::RichText::Content, result
  end

  def test_read_returns_correct_html
    article = Article.create!
    article.content = "<p>Hello <strong>world</strong></p>"
    article.save!

    article.reload

    assert_equal "<p>Hello <strong>world</strong></p>", article.content.to_html
  end

  def test_read_returns_plain_text
    article = Article.create!
    article.content = "<p>Hello <strong>world</strong></p>"
    article.save!

    article.reload

    assert_equal "Hello world", article.content.to_plain_text
  end

  def test_read_returns_nil_for_missing_translation
    article = Article.create!

    assert_nil article.content
  end

  def test_write_stores_html_string
    article = Article.create!
    article.content = "<p>Test content</p>"
    article.save!

    # Check the raw stored value
    translation = Mobility::Backends::ActiveRecord::KeyValue::TextTranslation
                  .find_by(translatable: article, key: "content")

    assert_equal "<p>Test content</p>", translation.value
  end

  def test_write_accepts_content_instance
    article = Article.create!
    content = Mobility::RichText::Content.new("<p>Rich text</p>")
    article.content = content
    article.save!

    article.reload

    assert_equal "<p>Rich text</p>", article.content.to_html
  end

  def test_write_accepts_action_text_content
    article = Article.create!
    action_text = ActionText::Content.new("<p>ActionText content</p>")
    article.content = action_text
    article.save!

    article.reload

    assert_equal "<p>ActionText content</p>", article.content.to_html
  end

  def test_multiple_locales
    article = Article.create!

    Mobility.with_locale(:en) do
      article.content = "<p>English content</p>"
    end

    Mobility.with_locale(:es) do
      article.content = "<p>Contenido en español</p>"
    end

    article.save!
    article.reload

    Mobility.with_locale(:en) do
      assert_equal "<p>English content</p>", article.content.to_html
    end

    Mobility.with_locale(:es) do
      assert_equal "<p>Contenido en español</p>", article.content.to_html
    end
  end

  def test_bypass_returns_raw_string
    article = Article.create!
    article.content = "<p>Hello</p>"
    article.save!

    article.reload
    raw = article.content(rich_text: false)

    assert_equal "<p>Hello</p>", raw
    assert_instance_of String, raw
  end

  def test_blank_and_present_methods
    article = Article.create!
    article.content = "<p>Hello</p>"
    article.save!

    article.reload

    refute article.content.blank?
    assert article.content.present?
  end

  def test_empty_content_treated_as_no_translation
    article = Article.create!
    article.content = ""
    article.save!

    article.reload

    # Mobility treats empty strings as "no translation" - returns nil
    assert_nil article.content
  end

  def test_round_trip_preserves_complex_html
    html = '<div class="content"><h1>Title</h1><p>Paragraph with <em>emphasis</em></p></div>'
    article = Article.create!
    article.content = html
    article.save!

    article.reload

    assert_equal html, article.content.to_html
  end
end
