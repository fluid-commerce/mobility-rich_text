# frozen_string_literal: true

require "test_helper"
require "active_record"
require "mobility"

# Set up in-memory SQLite database for integration tests
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Create tables for Mobility backends
ActiveRecord::Schema.define do
  # Articles table for testing
  create_table :articles, force: true do |t|
    t.string :title
    t.timestamps
  end

  # KeyValue backend tables (Mobility's default)
  create_table :mobility_string_translations, force: true do |t|
    t.string :locale, null: false
    t.string :key, null: false
    t.string :value
    t.references :translatable, polymorphic: true, index: false
    t.timestamps null: false
  end
  add_index :mobility_string_translations,
            %i[translatable_id translatable_type locale key],
            unique: true,
            name: "index_mobility_string_translations_on_keys"

  create_table :mobility_text_translations, force: true do |t|
    t.string :locale, null: false
    t.string :key, null: false
    t.text :value
    t.references :translatable, polymorphic: true, index: false
    t.timestamps null: false
  end
  add_index :mobility_text_translations,
            %i[translatable_id translatable_type locale key],
            unique: true,
            name: "index_mobility_text_translations_on_keys"

  # Table backend - Article translations
  create_table :article_translations, force: true do |t|
    t.string :locale, null: false
    t.references :article, null: false, foreign_key: true
    t.text :content
    t.timestamps null: false
  end
  add_index :article_translations, %i[article_id locale], unique: true

  # Container backend - Posts with JSON column
  create_table :posts, force: true do |t|
    t.string :title
    t.text :content_translations, default: "{}" # Serialized JSON for container backend
    t.timestamps
  end
end

# Configure I18n available locales
I18n.available_locales = %i[en es fr de]
I18n.default_locale = :en

# Configure Mobility
Mobility.configure do |config|
  config.plugins do
    backend
    reader
    writer
    active_record
    rich_text # Our plugin
  end
end

# Test model using KeyValue backend
class Article < ActiveRecord::Base
  extend Mobility

  translates :content, backend: :key_value, type: :text, rich_text: true
end

# Translation model for Table backend
class ArticleTranslation < ActiveRecord::Base
  belongs_to :article
end

# Test model using Table backend
class ArticleWithTableBackend < ActiveRecord::Base
  self.table_name = "articles"
  extend Mobility

  translates :content,
             backend: :table,
             table_name: :article_translations,
             foreign_key: :article_id,
             rich_text: true
end

# Test model using Container backend (JSON serialization)
class Post < ActiveRecord::Base
  extend Mobility

  # Serialize the translations column as JSON for SQLite
  serialize :content_translations, coder: JSON

  translates :content, backend: :container, column_name: :content_translations, rich_text: true
end
