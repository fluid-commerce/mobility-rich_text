# mobility-rich_text - Architecture & Design Plan

**Feature:** Mobility Rich Text Plugin
**Version:** 1.0

> **Note:** This document explains HOW we'll implement the plugin. For WHAT to build, see [spec.md](./spec.md). For step-by-step tasks, see [tasks.md](./tasks.md).

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [File Structure](#file-structure)
3. [Key Design Decisions](#key-design-decisions)
4. [Implementation Approach](#implementation-approach)
5. [Data Flow](#data-flow)
6. [Documentation Standards](#documentation-standards)
7. [Type Signatures](#type-signatures)

---

## Architecture Overview

### Plugin Architecture (Not Custom Backend)

This gem creates a **Mobility Plugin**, not a custom backend. This is a critical architectural decision.

```
┌─────────────────────────────────────────────────────────────────┐
│                     Application Code                             │
│  article.content = "<p>Hello</p>"                               │
│  article.content  # => Wrapper                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│               Mobility::Plugins::RichText                        │
│  • Intercepts read → wraps with ActionText::Content             │
│  • Intercepts write → extracts HTML string                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Any Mobility Backend                           │
│  • KeyValue, Table, JSON, JSONB, Hstore, etc.                   │
│  • Stores/retrieves plain HTML strings                          │
└─────────────────────────────────────────────────────────────────┘
```

### Why Plugin Architecture?

| Approach | Pros | Cons |
|----------|------|------|
| **Plugin (chosen)** | Works with ALL backends, clean separation, follows Mobility patterns | Adds processing layer |
| **Custom Backend** | Direct control | Only works with that backend, duplicates existing backend code |
| **Backend Decorator** | Some flexibility | Complex inheritance, fragile |

**Decision:** Plugin architecture provides maximum compatibility with minimum complexity.

---

## File Structure

### Gem Layout

```
lib/
├── mobility/
│   └── rich_text/
│       ├── version.rb              # Gem version
│       ├── wrapper.rb              # ActionText::Content wrapper
│       └── plugins/
│           └── rich_text.rb        # Mobility plugin
└── mobility/
    └── rich_text.rb                # Entry point (requires all files)

test/
├── mobility/
│   └── rich_text/
│       ├── wrapper_test.rb         # Wrapper unit tests
│       └── plugins/
│           └── rich_text_test.rb   # Plugin unit tests
└── integration/
    └── backend_compatibility_test.rb  # Multi-backend tests
```

### Critical Files

| File | Purpose |
|------|---------|
| `lib/mobility/rich_text.rb` | Entry point, requires dependencies, registers plugin |
| `lib/mobility/rich_text/wrapper.rb` | Wraps ActionText::Content with consistent interface |
| `lib/mobility/rich_text/plugins/rich_text.rb` | Mobility plugin with read/write hooks |

---

## Key Design Decisions

### 1. Use ActionText::Content, Not ActionText::RichText

**Decision:** Wrap values with `ActionText::Content`, not `ActionText::RichText`.

**Rationale:**
- ✅ `ActionText::Content` is a lightweight value object (no DB association)
- ✅ Provides all formatting/rendering capabilities
- ✅ Parses and renders `<action-text-attachment>` tags
- ✅ No need for `ActionText::RichText` model (has DB dependencies)

**Code Example:**
```ruby
# We use this (lightweight, no DB):
content = ActionText::Content.new("<p>Hello</p>")

# NOT this (requires DB record):
rich_text = ActionText::RichText.new(body: "<p>Hello</p>")
```

### 2. Create Wrapper Class for Future Extensibility

**Decision:** Create `Mobility::RichText::Wrapper` that delegates to `ActionText::Content`.

**Rationale:**
- ✅ Provides consistent interface across Rails versions
- ✅ Allows future enhancements without changing API
- ✅ Can add Mobility-specific methods (model/attribute context)
- ✅ Clear type for checking (`is_a? Mobility::RichText::Wrapper`)

**Code Example:**
```ruby
class Mobility::RichText::Wrapper
  delegate_missing_to :@content

  def initialize(html)
    @content = ActionText::Content.new(html.to_s)
  end

  def to_action_text_content
    @content
  end
end
```

### 3. Plugin Uses included_hook for Backend Injection

**Decision:** Use Mobility's `included_hook` to inject methods into backend classes.

**Rationale:**
- ✅ Standard Mobility plugin pattern
- ✅ Works with any backend without backend modifications
- ✅ Clean separation between plugin and backend

**Code Example:**
```ruby
module Mobility::Plugins::RichText
  extend Mobility::Plugin

  included_hook do |klass|
    klass.include BackendMethods
  end
end
```

### 4. Handle All Input Types on Write

**Decision:** Accept multiple input types and normalize to HTML string.

**Rationale:**
- ✅ Developer-friendly (accepts what they have)
- ✅ Works with Trix editor output
- ✅ Works with programmatic ActionText creation

**Accepted Types:**
- `String` - Pass through as-is
- `ActionText::Content` - Extract with `.to_html`
- `ActionText::RichText` - Extract with `.body.to_html`
- `Mobility::RichText::Wrapper` - Extract with `.to_html`
- `nil` - Pass through as-is

---

## Implementation Approach

### Phase Structure

| Phase | Focus | Deliverables |
|-------|-------|--------------|
| **1: Foundation** | Wrapper class | `wrapper.rb` with tests |
| **2: Plugin Core** | Plugin module | `plugins/rich_text.rb` with tests |
| **3: Backend Testing** | Compatibility | Integration tests with multiple backends |
| **4: Attachment Testing** | Full features | Attachment integration tests |

### Phase 1: Foundation (Wrapper Class)

**Goal:** Create the Wrapper class that provides a consistent interface.

```ruby
# lib/mobility/rich_text/wrapper.rb
module Mobility
  module RichText
    class Wrapper
      delegate_missing_to :@content

      def initialize(html)
        @html = html.to_s
        @content = ActionText::Content.new(@html)
      end

      def to_s
        @content.to_s
      end

      def to_html
        @content.to_html
      end

      def to_plain_text
        @content.to_plain_text
      end

      def blank?
        @content.blank?
      end

      def present?
        !blank?
      end

      def to_action_text_content
        @content
      end

      def ==(other)
        case other
        when Wrapper then to_html == other.to_html
        when ActionText::Content then to_html == other.to_html
        when String then to_html == other
        else false
        end
      end
    end
  end
end
```

### Phase 2: Plugin Core

**Goal:** Create the Mobility plugin with read/write hooks.

```ruby
# lib/mobility/rich_text/plugins/rich_text.rb
module Mobility
  module Plugins
    module RichText
      extend Mobility::Plugin

      default false

      included_hook do |klass|
        klass.include(BackendMethods) if options[:rich_text]
      end

      module BackendMethods
        def read(locale, **options)
          return super if options[:rich_text] == false

          value = super
          return nil if value.nil?

          Mobility::RichText::Wrapper.new(value)
        end

        def write(locale, value, **options)
          normalized = normalize_value(value)
          super(locale, normalized, **options)
        end

        private

        def normalize_value(value)
          case value
          when nil then nil
          when String then value
          when Mobility::RichText::Wrapper then value.to_html
          when ActionText::Content then value.to_html
          when ActionText::RichText then value.body.to_html
          else value.to_s
          end
        end
      end
    end

    register_plugin(:rich_text, RichText)
  end
end
```

### Phase 3: Backend Testing

**Goal:** Verify compatibility with all major Mobility backends.

Test matrix:
- KeyValue backend (string and text types)
- Table backend
- JSON backend (if ActiveRecord adapter supports)
- JSONB backend (PostgreSQL)
- Hstore backend (PostgreSQL)

### Phase 4: Attachment Testing

**Goal:** Verify ActionText attachment features work correctly.

Test scenarios:
- Parse HTML with `<action-text-attachment>` tags
- Render attachments via `render_attachments`
- Gallery attachment grouping
- SGID lookup (requires ActiveStorage fixtures)

---

## Data Flow

### Read Flow

```
1. Application reads attribute
   article.content
   └─> Mobility dispatches to backend

2. Backend reads from storage
   └─> Returns HTML string: "<p>Hello</p>"

3. RichText plugin intercepts
   └─> Wraps with Wrapper.new(html_string)

4. Application receives Wrapper
   └─> Can call .to_s, .to_plain_text, etc.
```

### Write Flow

```
1. Application writes attribute
   article.content = ActionText::Content.new("<p>Hello</p>")
   └─> Mobility dispatches to backend

2. RichText plugin intercepts
   └─> Normalizes: ActionText::Content → "<p>Hello</p>"

3. Backend receives HTML string
   └─> Stores in database/JSON/etc.
```

---

## Documentation Standards

### TomDoc Format

All Ruby code must be documented using [TomDoc](https://github.com/mojombo/tomdoc) markup format. TomDoc provides human-readable documentation that can also be parsed by tools like RDoc.

### Documentation Generation

Documentation is generated using the `rdoc` gem, which has built-in TomDoc support via `RDoc::TomDoc`.

```bash
# Generate documentation
bundle exec rdoc lib/

# Generate with specific format
bundle exec rdoc --format=darkfish lib/
```

### TomDoc Structure

Each documented element follows this structure:

1. **Description** - Plain sentences explaining what the method does
2. **Arguments** - Each parameter with name, dash, and explanation
3. **Examples** - Code examples showing usage (optional)
4. **Returns** - What the method returns
5. **Raises** - Exceptions that may be raised (optional)

### Visibility Markers

Use these prefixes to indicate method visibility:

- `Public:` - Part of the public API, follows semantic versioning
- `Internal:` - For internal use only, may change without notice
- `Deprecated:` - Will be removed in future major version

### Example: Class Documentation

```ruby
# Public: Wraps an HTML string with ActionText::Content functionality.
#
# This class provides a consistent interface for rich text content,
# delegating most methods to the underlying ActionText::Content while
# adding Mobility-specific functionality.
#
# Examples
#
#   wrapper = Mobility::RichText::Wrapper.new("<p>Hello</p>")
#   wrapper.to_plain_text
#   # => "Hello"
#
class Wrapper
  # ...
end
```

### Example: Method Documentation

```ruby
# Public: Creates a new Wrapper instance.
#
# html - The String HTML content to wrap. Will be converted to String
#        if another type is provided. Nil values become empty strings.
#
# Examples
#
#   Wrapper.new("<p>Hello</p>")
#   # => #<Mobility::RichText::Wrapper ...>
#
#   Wrapper.new(nil)
#   # => #<Mobility::RichText::Wrapper @html="">
#
# Returns a new Wrapper instance.
def initialize(html)
  @html = html.to_s
  @content = ActionText::Content.new(@html)
end
```

### Example: Method with Multiple Arguments

```ruby
# Public: Compares this wrapper with another object for equality.
#
# other - The Object to compare against. Can be:
#         Wrapper - compares HTML content
#         ActionText::Content - compares HTML content
#         String - compares against HTML string
#
# Examples
#
#   wrapper = Wrapper.new("<p>Hi</p>")
#   wrapper == Wrapper.new("<p>Hi</p>")
#   # => true
#
#   wrapper == "<p>Hi</p>"
#   # => true
#
# Returns true if the objects are considered equal, false otherwise.
def ==(other)
  # ...
end
```

### Example: Internal Method

```ruby
# Internal: Normalizes various input types to an HTML string.
#
# value - The value to normalize. Accepts String, Wrapper,
#         ActionText::Content, ActionText::RichText, or nil.
#
# Returns the String HTML representation, or nil if value was nil.
def normalize_value(value)
  # ...
end
```

### Example: Attribute Documentation

```ruby
# Public: Returns the String HTML content.
attr_reader :html

# Public: Returns the underlying ActionText::Content instance.
attr_reader :content
```

### Documentation Checklist

For each class/module:
- [ ] Class-level TomDoc with description and examples
- [ ] All public methods documented
- [ ] All public attributes documented
- [ ] Internal methods marked with `Internal:` prefix
- [ ] Examples provided for non-obvious usage

---

## Type Signatures

### RBS Format

All Ruby code must have type signatures documented using [RBS](https://github.com/ruby/rbs) (Ruby Signature) format. RBS is Ruby's official type signature language.

### File Structure

RBS signatures are stored in the `sig/` directory, mirroring the `lib/` structure:

```
sig/
└── mobility/
    └── rich_text/
        ├── wrapper.rbs           # Wrapper class types
        └── plugins/
            └── rich_text.rbs     # Plugin types
```

### Type Validation

```bash
# Validate RBS syntax
bundle exec rbs validate

# Type check with Steep (optional)
bundle exec steep check
```

### Example: Wrapper Class Signature

```rbs
# sig/mobility/rich_text/wrapper.rbs
module Mobility
  module RichText
    class Wrapper
      @html: String
      @content: ActionText::Content

      attr_reader content: ActionText::Content

      def initialize: (String? html) -> void

      def to_s: () -> String
      def to_html: () -> String
      def to_plain_text: () -> String
      def blank?: () -> bool
      def present?: () -> bool
      def to_action_text_content: () -> ActionText::Content

      def ==: (Wrapper | ActionText::Content | String | untyped other) -> bool
    end
  end
end
```

### Example: Plugin Signature

```rbs
# sig/mobility/rich_text/plugins/rich_text.rbs
module Mobility
  module Plugins
    module RichText
      extend Mobility::Plugin

      module BackendMethods
        def read: (Symbol locale, **untyped options) -> Mobility::RichText::Wrapper?
        def write: (Symbol locale, untyped value, **untyped options) -> void

        private

        def normalize_value: (untyped value) -> String?
      end
    end
  end
end
```

### RBS Conventions

1. **Nullable Types:** Use `Type?` for types that can be nil
2. **Union Types:** Use `Type1 | Type2` for multiple possible types
3. **Instance Variables:** Declare with `@name: Type`
4. **Block Parameters:** Use `{ (Type) -> ReturnType }` syntax
5. **Keyword Arguments:** Use `name: Type` or `?name: Type` for optional

### Type Signature Checklist

For each class/module:
- [ ] RBS file created in `sig/` directory
- [ ] All public methods have signatures
- [ ] All public attributes typed
- [ ] Instance variables declared
- [ ] `rbs validate` passes
- [ ] Types match implementation

---

## What NOT To Do

**Don't create a custom backend**
→ Use a plugin that wraps any backend instead.

**Don't store ActionText::Content objects directly**
→ Always convert to HTML strings for storage.

**Don't require ActionText::RichText model**
→ Use ActionText::Content which has no DB dependencies.

**Don't modify existing Mobility backends**
→ Use the plugin system to inject behavior.

**Don't assume specific backend storage format**
→ Only assume backends store/retrieve strings.

---

## Success Metrics

**Technical:**
- ✅ Works with all listed Mobility backends
- ✅ All ActionText features available
- ✅ No database schema changes required
- ✅ Comprehensive test coverage

**Developer Experience:**
- ✅ Simple configuration: `rich_text: true`
- ✅ Intuitive API matching ActionText patterns
- ✅ Clear documentation with examples

---

## Related Documentation

### Within This Feature

- **[spec.md](./spec.md)** - What to build
- **[tasks.md](./tasks.md)** - Step-by-step implementation
- **[summary.md](./summary.md)** - Executive status
- **[extras/](./extras/)** - Supporting details

### External

- [Mobility Plugin Guide](https://github.com/shioyama/mobility/wiki/Plugins)
- [ActionText::Content source](https://github.com/rails/rails/blob/main/actiontext/lib/action_text/content.rb)
- [TomDoc Specification](https://github.com/mojombo/tomdoc)
- [RDoc TomDoc Parser](https://docs.ruby-lang.org/en/master/RDoc/TomDoc.html)
- [Tom Preston-Werner's TomDoc Introduction](https://tom.preston-werner.com/2010/05/11/tomdoc-reasonable-ruby-documentation.html)
- [RBS Repository](https://github.com/ruby/rbs)
- [RBS Syntax Guide](https://github.com/ruby/rbs/blob/master/docs/syntax.md)
- [Steep Type Checker](https://github.com/soutaro/steep)

---

**Document Owner:** Development Team
**Review Status:** Draft
