# Mobility::RichText

A [Mobility](https://github.com/shioyama/mobility) plugin that wraps translated string values with `ActionText::Content`, enabling rich text editing for internationalized content without separate ActionText storage.

## Why Use This?

**Problem:** You want rich text editing for translated content, but `mobility-actiontext` requires separate `ActionText::RichText` records per locale, adding database complexity.

**Solution:** `mobility-rich_text` wraps your existing backend's string values with `ActionText::Content`, giving you full rich text capabilities with simpler storage:

- Works with **all** Mobility backends (KeyValue, Table, JSON, JSONB, Hstore)
- **No additional database tables** or migrations required
- Full ActionText features: Trix editor, attachments, rendering
- Simple configuration: just add `rich_text: true` to your attribute

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mobility-rich_text"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install mobility-rich_text
```

## Usage

### Configuration

Add the `rich_text` plugin to your Mobility configuration and enable it on specific attributes:

```ruby
# config/initializers/mobility.rb
Mobility.configure do |config|
  config.plugins do
    backend
    reader
    writer
    active_record
    rich_text  # Add the plugin
  end
end
```

### Model Setup

```ruby
class Article < ApplicationRecord
  extend Mobility

  # Standard translated attribute (no rich text)
  translates :title, backend: :key_value, type: :string

  # Rich text translated attribute
  translates :content, backend: :key_value, type: :text, rich_text: true
end
```

### Reading Values

```ruby
article = Article.find(1)

# Returns Mobility::RichText::Content (delegates to ActionText::Content)
article.content
# => #<Mobility::RichText::Content ...>

# Access ActionText methods
article.content.to_s           # Renders HTML
article.content.to_plain_text  # Strips HTML tags
article.content.to_html        # Returns HTML string
article.content.blank?         # Checks if content is empty

# Bypass rich text wrapping to get raw string
article.content(rich_text: false)
# => "<p>Raw HTML string</p>"
```

### Writing Values

```ruby
article = Article.new

# All of these work:
article.content = "<p>Plain HTML string</p>"
article.content = ActionText::Content.new("<p>Rich content</p>")
article.content = Mobility::RichText::Content.new("<p>Wrapped content</p>")

article.save!
# Stored as HTML string in your backend
```

### With Trix Editor

```erb
<%# In your form %>
<%= form_with model: @article do |form| %>
  <%= form.rich_text_area :content %>
<% end %>

<%# In your view %>
<%= @article.content %>
```

### Multiple Locales

```ruby
article = Article.new

Mobility.with_locale(:en) do
  article.content = "<p>English content</p>"
end

Mobility.with_locale(:es) do
  article.content = "<p>Contenido en español</p>"
end

article.save!
```

## How It Works

This plugin intercepts reads and writes on translated attributes:

- **On read:** Wraps the HTML string from your backend with `ActionText::Content`
- **On write:** Converts ActionText objects back to HTML strings for storage

```
┌─────────────────────────────────────────────────────────────────┐
│                     Application Code                            │
│  article.content = "<p>Hello</p>"                               │
│  article.content  # => Mobility::RichText::Content              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│               Mobility::Plugins::RichText                       │
│  • Intercepts read → wraps with ActionText::Content             │
│  • Intercepts write → extracts HTML string                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Any Mobility Backend                          │
│  • KeyValue, Table, JSON, JSONB, Hstore, etc.                   │
│  • Stores/retrieves plain HTML strings                          │
└─────────────────────────────────────────────────────────────────┘
```

## Comparison with mobility-actiontext

| Feature | mobility-actiontext | mobility-rich_text |
|---------|---------------------|-------------------|
| Storage | Separate ActionText records | Your existing backend |
| Backends | Limited (needs associations) | All backends |
| Schema changes | Yes (ActionText tables) | None |
| Attachments | Full support | Full support |
| Rich text editing | Full support | Full support |

## Attachments

ActionText attachments are fully supported. Attachment tags are stored inline in the HTML:

```html
<action-text-attachment sgid="..." content-type="image/png" filename="photo.png">
</action-text-attachment>
```

Access attachments via the standard ActionText API:

```ruby
article.content.attachments        # All attachments
article.content.gallery_attachments # Gallery attachments
article.content.links              # All links in content
```

**Note:** Attachments require ActiveStorage to be configured in your Rails application.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

```bash
# Run all tests
bundle exec rake test

# Run linter
bundle exec rake rubocop

# Validate RBS type signatures
bundle exec rake rbs

# Run Steep type checker
bundle exec rake steep

# Run all checks
bundle exec rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fluid-commerce/mobility-rich_text. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fluid-commerce/mobility-rich_text/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mobility::RichText project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fluid-commerce/mobility-rich_text/blob/main/CODE_OF_CONDUCT.md).
