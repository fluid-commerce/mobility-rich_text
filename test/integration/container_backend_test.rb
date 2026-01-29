# frozen_string_literal: true

require_relative "integration_helper"

class ContainerBackendTest < Minitest::Test
  def setup
    Post.delete_all
  end

  def test_read_returns_content_instance
    post = Post.create!
    post.content = "<p>Hello world</p>"
    post.save!

    post.reload
    result = post.content

    assert_instance_of Mobility::RichText::Content, result
  end

  def test_read_returns_correct_html
    post = Post.create!
    post.content = "<p>Hello <strong>world</strong></p>"
    post.save!

    post.reload

    assert_equal "<p>Hello <strong>world</strong></p>", post.content.to_html
  end

  def test_read_returns_plain_text
    post = Post.create!
    post.content = "<p>Hello <strong>world</strong></p>"
    post.save!

    post.reload

    assert_equal "Hello world", post.content.to_plain_text
  end

  def test_read_returns_nil_for_missing_translation
    post = Post.create!

    assert_nil post.content
  end

  def test_write_stores_html_in_json_column
    post = Post.create!
    post.content = "<p>Test content</p>"
    post.save!

    post.reload
    # Container backend stores in a JSON-serialized column
    raw_data = post.read_attribute(:content_translations)

    assert_includes raw_data.to_s, "Test content"
  end

  def test_write_accepts_content_instance
    post = Post.create!
    content = Mobility::RichText::Content.new("<p>Rich text</p>")
    post.content = content
    post.save!

    post.reload

    assert_equal "<p>Rich text</p>", post.content.to_html
  end

  def test_multiple_locales
    post = Post.create!

    Mobility.with_locale(:en) do
      post.content = "<p>English content</p>"
    end

    Mobility.with_locale(:es) do
      post.content = "<p>Contenido en español</p>"
    end

    post.save!
    post.reload

    Mobility.with_locale(:en) do
      assert_equal "<p>English content</p>", post.content.to_html
    end

    Mobility.with_locale(:es) do
      assert_equal "<p>Contenido en español</p>", post.content.to_html
    end
  end

  def test_bypass_returns_raw_string
    post = Post.create!
    post.content = "<p>Hello</p>"
    post.save!

    post.reload
    raw = post.content(rich_text: false)

    assert_equal "<p>Hello</p>", raw
    assert_instance_of String, raw
  end

  def test_round_trip_preserves_complex_html
    html = '<div class="content"><h1>Title</h1><p>Paragraph with <em>emphasis</em></p></div>'
    post = Post.create!
    post.content = html
    post.save!

    post.reload

    assert_equal html, post.content.to_html
  end
end
