# mobility-rich_text - Business & Technical Specification

**Feature:** Mobility Rich Text Plugin
**Version:** 1.0

---

## Table of Contents

1. [Business Context](#business-context)
2. [Functional Requirements](#functional-requirements)
3. [API Specification](#api-specification)
4. [Data Model](#data-model)
5. [Acceptance Criteria](#acceptance-criteria)

---

## Business Context

### What Is mobility-rich_text?

**mobility-rich_text** is a Mobility plugin that wraps translated string values with `ActionText::Content`, providing rich text editing capabilities for internationalized content.

**Key Concept:** This plugin doesn't store data differently - it transforms data at read/write time:
- On **read**: Wraps the HTML string from your backend with `ActionText::Content`
- On **write**: Converts ActionText objects back to HTML strings for storage

### Why Use This Plugin?

**Problem:** You want rich text editing for translated content, but:
- `mobility-actiontext` requires separate `ActionText::RichText` records per locale
- Adds database complexity with multiple join tables
- Doesn't work with all Mobility backends (only those supporting associations)

**Solution:** mobility-rich_text provides:
- Full ActionText features (Trix editor, attachments, rendering)
- Works with ANY Mobility backend (KeyValue, Table, JSON, JSONB, Hstore)
- No additional database tables or schema changes
- Simple string storage in your existing backend

### Comparison with mobility-actiontext

| Feature | mobility-actiontext | mobility-rich_text |
|---------|---------------------|-------------------|
| Storage | Separate ActionText records | Your existing backend |
| Backends | Limited (needs associations) | ALL backends |
| Schema changes | Yes (ActionText tables) | None |
| Attachments | Full support | Full support |
| Rich text editing | Full support | Full support |
| Database complexity | Higher | Lower |

### Use Cases

- **CMS with multiple backends:** Use JSON backend for simple sites, KeyValue for enterprise
- **Existing translations:** Add rich text without migrating data structure
- **Performance-critical apps:** Avoid extra joins for translations
- **Simple deployments:** No additional migrations required

---

## Functional Requirements

### FR-RT-001: Plugin Registration

**Priority:** P0 (Critical)

The plugin must register with Mobility's plugin system and be configurable per-attribute.

**Acceptance Criteria:**
- AC-RT-001.1: Plugin registers via `Mobility::Plugins.register_plugin(:rich_text, RichText)`
- AC-RT-001.2: Plugin activates with `rich_text: true` option on `translates` macro
- AC-RT-001.3: Plugin is disabled by default (must explicitly enable)

### FR-RT-002: Read Interception

**Priority:** P0 (Critical)

When reading a translated attribute, the plugin wraps the string value with ActionText::Content.

**Acceptance Criteria:**
- AC-RT-002.1: Returns `Mobility::RichText::Content` instance wrapping `ActionText::Content`
- AC-RT-002.2: Returns `nil` when backend returns `nil`
- AC-RT-002.3: Returns empty wrapper when backend returns empty string
- AC-RT-002.4: Handles HTML strings with proper encoding

### FR-RT-003: Write Interception

**Priority:** P0 (Critical)

When writing a translated attribute, the plugin converts ActionText objects to HTML strings.

**Acceptance Criteria:**
- AC-RT-003.1: Accepts plain strings (passes through unchanged)
- AC-RT-003.2: Accepts `ActionText::Content` objects, extracts HTML
- AC-RT-003.3: Accepts `ActionText::RichText` objects, extracts HTML
- AC-RT-003.4: Accepts `Mobility::RichText::Content` objects, extracts HTML
- AC-RT-003.5: Handles `nil` values (passes through)

### FR-RT-004: Attachment Support

**Priority:** P1 (High)

The plugin must support ActionText attachments (images, files, embeds).

**Acceptance Criteria:**
- AC-RT-004.1: `<action-text-attachment>` tags in HTML are parsed correctly
- AC-RT-004.2: Attachments render properly via `ActionText::Content#render_attachments`
- AC-RT-004.3: Gallery attachments (multiple images) display correctly
- AC-RT-004.4: SGID-based attachment lookups work correctly

### FR-RT-005: Backend Compatibility

**Priority:** P0 (Critical)

The plugin must work with all Mobility backends without modification.

**Acceptance Criteria:**
- AC-RT-005.1: Works with KeyValue backend
- AC-RT-005.2: Works with Table backend
- AC-RT-005.3: Works with JSON/JSONB backends
- AC-RT-005.4: Works with Hstore backend
- AC-RT-005.5: Does not require backend-specific code

### FR-RT-006: Bypass Mechanism

**Priority:** P2 (Nice to Have)

Users can bypass rich text wrapping to get raw string value.

**Acceptance Criteria:**
- AC-RT-006.1: `model.content(rich_text: false)` returns raw string
- AC-RT-006.2: Bypass works for read operations only
- AC-RT-006.3: Does not affect write operations

### FR-RT-007: Code Documentation

**Priority:** P1 (High)

All Ruby code must be documented using TomDoc markup format, with documentation generated via the rdoc gem.

**Acceptance Criteria:**
- AC-RT-007.1: All public methods documented with TomDoc format
- AC-RT-007.2: All public classes documented with TomDoc format
- AC-RT-007.3: Internal methods marked with `Internal:` visibility prefix
- AC-RT-007.4: Deprecated methods marked with `Deprecated:` visibility prefix
- AC-RT-007.5: Documentation generates successfully via `rdoc` command
- AC-RT-007.6: Generated documentation is readable and complete

### FR-RT-008: Type Signatures

**Priority:** P1 (High)

All Ruby code must have type signatures documented using RBS (Ruby Signature) format.

**Acceptance Criteria:**
- AC-RT-008.1: RBS signatures provided for all public classes in `sig/` directory
- AC-RT-008.2: RBS signatures provided for all public methods
- AC-RT-008.3: Type signatures validate successfully via `rbs validate`
- AC-RT-008.4: Type signatures match implementation (verified via `steep check` or similar)

---

## API Specification

### Plugin Configuration

```ruby
# In model
class Article < ApplicationRecord
  extend Mobility

  # Enable rich_text plugin for specific attribute
  translates :title, backend: :key_value  # No rich text
  translates :content, backend: :key_value, rich_text: true  # With rich text
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
article.content.to_plain_text  # Strips HTML
article.content.blank?         # Checks content

# Bypass rich text wrapping
article.content(rich_text: false)
# => "<p>Raw HTML string</p>"
```

### Writing Values

```ruby
article = Article.new

# All these work:
article.content = "<p>Plain HTML string</p>"
article.content = ActionText::Content.new("<p>Rich content</p>")
article.content = some_action_text_rich_text_object.body

article.save!
# Stored as HTML string in backend
```

### With Trix Editor

```erb
<%# In form - use standard Trix integration %>
<%= form.rich_text_area :content %>

<%# In view - render rich text %>
<%= article.content %>
```

### Content Class Methods

The `Mobility::RichText::Content` class delegates to `ActionText::Content`:

```ruby
wrapper = Mobility::RichText::Content.new("<p>Hello</p>")

# Delegation to ActionText::Content
wrapper.to_s              # => "<p>Hello</p>"
wrapper.to_plain_text     # => "Hello"
wrapper.to_html           # => "<p>Hello</p>"
wrapper.blank?            # => false
wrapper.present?          # => true
wrapper.attachments       # => []
wrapper.gallery_attachments # => []
wrapper.render_attachments  # Renders with blocks

# Direct access
wrapper.to_action_text_content  # => ActionText::Content instance
```

---

## Data Model

### No Database Changes Required

This plugin does not require any database schema changes. It works with your existing Mobility backend tables.

### Data Storage Format

Data is stored as HTML strings in your backend:

```ruby
# KeyValue backend stores:
# mobility_string_translations:
#   key: "content"
#   value: "<div class=\"trix-content\"><p>Hello <strong>world</strong></p></div>"
#   locale: "en"

# JSON backend stores:
# articles.content_translations:
#   { "en": "<div class=\"trix-content\">...</div>", "es": "<div>...</div>" }
```

### Attachment Data

Attachments are stored inline as `<action-text-attachment>` tags:

```html
<action-text-attachment
  sgid="BAh7CEkiCGdpZAY6BkVUSSIvZ2lkOi8vYXBwL0FjdGl2ZVN0b3JhZ2U6OkJsb2IvMT9leHBpcmVzX2luBjsAVEkiDHB1cnBvc2UGOwBUSSIPYXR0YWNoYWJsZQY7AFRJIg9leHBpcmVzX2F0BjsAVDA=--abc123"
  content-type="image/jpeg"
  filename="photo.jpg">
</action-text-attachment>
```

**Note:** Attachments require ActiveStorage to be configured. The SGID (Signed Global ID) allows ActionText to look up the attached blob.

---

## Acceptance Criteria

### Overall Acceptance Criteria

The mobility-rich_text gem is considered **complete** when:

#### Must Have (P0) - Blocking Release

- [ ] Plugin registers with Mobility
- [ ] Read interception wraps values with ActionText::Content
- [ ] Write interception converts objects to HTML strings
- [ ] Works with KeyValue backend
- [ ] Works with Table backend
- [ ] Works with JSON/JSONB backends
- [ ] Comprehensive test suite
- [ ] Documentation complete
- [ ] All tests passing

#### Should Have (P1) - Important

- [ ] Attachment support works correctly
- [ ] Hstore backend tested
- [ ] Bypass mechanism implemented
- [ ] Performance benchmarks acceptable
- [ ] All public API documented with TomDoc
- [ ] RDoc generates successfully
- [ ] RBS type signatures for all public API
- [ ] Type signatures validate via `rbs validate`

#### Nice to Have (P2) - Future Enhancement

- [ ] Caching support
- [ ] Custom wrapper class option
- [ ] Sanitization options

---

## Related Documentation

### Within This Feature

- **[plan.md](./plan.md)** - Architecture and design decisions
- **[tasks.md](./tasks.md)** - Implementation checklist
- **[summary.md](./summary.md)** - Executive status
- **[extras/](./extras/)** - Supporting details

### External

- [Mobility gem documentation](https://github.com/shioyama/mobility)
- [Mobility plugins guide](https://github.com/shioyama/mobility/wiki/Plugins)
- [ActionText overview](https://edgeguides.rubyonrails.org/action_text_overview.html)
- [ActionText::Content API](https://api.rubyonrails.org/classes/ActionText/Content.html)
- [TomDoc specification](https://github.com/mojombo/tomdoc)
- [RDoc TomDoc parser](https://docs.ruby-lang.org/en/master/RDoc/TomDoc.html)
- [RBS documentation](https://github.com/ruby/rbs)
- [RBS syntax guide](https://github.com/ruby/rbs/blob/master/docs/syntax.md)

---

**Document Owner:** Development Team
**Approval Status:** Draft
