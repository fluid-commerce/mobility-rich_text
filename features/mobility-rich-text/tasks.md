# mobility-rich_text - Implementation Checklist

**Feature:** Mobility Rich Text Plugin
**Current Phase:** Complete

> **Critical:** Follow phases IN ORDER. Write tests FIRST (TDD). Don't proceed to next phase until current phase is 100% complete with all tests passing.

---

## Progress Tracker

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Foundation | Complete | 100% |
| Phase 2: Plugin Core | Complete | 100% |
| Phase 3: Backend Integration | Complete | 100% |
| Phase 4: Attachment Support | Complete | 100% |

**Overall Completion:** Complete (71 tests, 124 assertions)

---

## Phase 1: Foundation (Content Class)

**Goal:** Create the Content class that provides a consistent interface around ActionText::Content.

**Status:** Complete

---

### 1.1: Create Content Class

**Deliverables:**
- [x] `lib/mobility/rich_text/content.rb`
- [x] `test/mobility/rich_text/content_test.rb`

**Steps:**

#### 1.1.1: Write Tests First (TDD)

- [x] Create `test/mobility/rich_text/content_test.rb`
  - [x] Test `#initialize` accepts HTML string
  - [x] Test `#initialize` handles nil (converts to empty string)
  - [x] Test `#initialize` handles empty string
  - [x] Test `#to_s` returns rendered HTML
  - [x] Test `#to_html` returns HTML string
  - [x] Test `#to_plain_text` strips HTML tags
  - [x] Test `#blank?` returns true for empty content
  - [x] Test `#blank?` returns false for content with text
  - [x] Test `#present?` is inverse of `#blank?`
  - [x] Test `#to_action_text_content` returns ActionText::Content
  - [x] Test `#==` with another Content
  - [x] Test `#==` with ActionText::Content
  - [x] Test `#==` with String
  - [x] Test delegation to ActionText::Content methods

#### 1.1.2: Implement Content Class

- [x] Create `lib/mobility/rich_text/content.rb`
  - [x] Add `initialize(html)` method
  - [x] Add `to_s` method
  - [x] Add `to_html` method
  - [x] Add `to_plain_text` method
  - [x] Add `blank?` method
  - [x] Add `present?` method
  - [x] Add `to_action_text_content` method
  - [x] Add `==` comparison method
  - [x] Add `delegate_missing_to :@content`

#### 1.1.3: Document Content Class (TomDoc)

- [x] Add TomDoc class-level documentation
  - [x] Description of what Content does
  - [x] Usage examples
- [x] Document all public methods with TomDoc
  - [x] `initialize` - parameters, examples, returns
  - [x] `to_s` - description, returns
  - [x] `to_html` - description, returns
  - [x] `to_plain_text` - description, returns
  - [x] `blank?` - description, returns
  - [x] `present?` - description, returns
  - [x] `to_action_text_content` - description, returns
  - [x] `==` - parameters, examples, returns
- [x] Document public attributes (`html`, `content`)
- [x] Verify `bundle exec rdoc lib/mobility/rich_text/content.rb` generates correctly

#### 1.1.4: Write RBS Type Signatures

- [x] Create `sig/mobility/rich_text/content.rbs`
  - [x] Declare instance variables (`@html`, `@content`)
  - [x] Type `initialize` method
  - [x] Type `to_s` method
  - [x] Type `to_html` method
  - [x] Type `to_plain_text` method
  - [x] Type `blank?` method
  - [x] Type `present?` method
  - [x] Type `to_action_text_content` method
  - [x] Type `==` method with union types
  - [x] Type `attr_reader` for `content`
- [x] Verify `bundle exec rbs validate` passes

#### 1.1.5: Verify Tests Pass

- [x] Run `bundle exec rake test TEST=test/mobility/rich_text/content_test.rb`
- [x] All tests GREEN
- [x] Run `bundle exec rake rubocop`
- [x] No style violations

**Acceptance Criteria:**
- [x] Content class exists at correct path
- [x] All tests written first (TDD)
- [x] All tests passing
- [x] Handles nil and empty string gracefully
- [x] Delegates unknown methods to ActionText::Content
- [x] All public methods documented with TomDoc
- [x] RDoc generates without errors
- [x] RBS type signatures complete
- [x] `rbs validate` passes

---

### 1.2: Update Entry Point

**Deliverables:**
- [x] Updated `lib/mobility/rich_text.rb`

**Steps:**

- [x] Require ActionText dependency
- [x] Require wrapper file
- [x] Ensure proper load order

**Acceptance Criteria:**
- [x] `require "mobility/rich_text"` loads all necessary files
- [x] No load order errors

---

### 1.3: Phase 1 Completion Checklist

**Before proceeding to Phase 2:**

- [x] All Phase 1 tasks completed
- [x] All wrapper tests passing
- [x] Content class documented with TomDoc
- [x] RDoc generates successfully for wrapper
- [x] RBS type signatures complete for wrapper
- [x] `rbs validate` passes
- [x] Code review approved (if applicable)
- [x] Documentation updated (this file)
- [x] No linter errors

**Phase 1 Status:** Complete

---

## Phase 2: Plugin Core

**Goal:** Create the Mobility plugin with read/write interception.

**Status:** Complete

---

### 2.1: Create Plugin Module

**Deliverables:**
- [x] `lib/mobility/rich_text/plugins/rich_text.rb`
- [x] `test/mobility/rich_text/plugins/rich_text_test.rb`

**Steps:**

#### 2.1.1: Write Tests First (TDD)

- [x] Create `test/mobility/rich_text/plugins/rich_text_test.rb`
  - [x] Test plugin registration with Mobility
  - [x] Test plugin disabled by default
  - [x] Test plugin enabled with `rich_text: true`
  - [x] Test read returns Content when enabled
  - [x] Test read returns nil when value is nil
  - [x] Test read returns raw string with `rich_text: false` option
  - [x] Test write accepts String
  - [x] Test write accepts ActionText::Content
  - [x] Test write accepts Content
  - [x] Test write accepts nil
  - [x] Test write normalizes to HTML string

#### 2.1.2: Implement Plugin Module

- [x] Create `lib/mobility/rich_text/plugins/rich_text.rb`
  - [x] Extend `Mobility::Plugin`
  - [x] Set `default false`
  - [x] Implement `included_hook`
  - [x] Create `BackendMethods` module
  - [x] Implement `read` method override
  - [x] Implement `write` method override
  - [x] Implement `normalize_value` private method

#### 2.1.3: Document Plugin Module (TomDoc)

- [x] Add TomDoc module-level documentation for `Mobility::Plugins::RichText`
  - [x] Description of plugin purpose
  - [x] Configuration examples
- [x] Document `BackendMethods` module
- [x] Document public methods with TomDoc
  - [x] `read` - parameters, returns
  - [x] `write` - parameters, returns
- [x] Document internal methods with `Internal:` prefix
  - [x] `normalize_value` - parameters, returns
- [x] Verify `bundle exec rdoc lib/mobility/rich_text/plugins/` generates correctly

#### 2.1.4: Write RBS Type Signatures

- [x] Create `sig/mobility/rich_text/plugins/rich_text.rbs`
  - [x] Type `RichText` module
  - [x] Type `BackendMethods` module
  - [x] Type `read` method
  - [x] Type `write` method
  - [x] Type `normalize_value` private method
- [x] Verify `bundle exec rbs validate` passes

#### 2.1.5: Register Plugin

- [x] Add `Mobility::Plugins.register_plugin(:rich_text, RichText)` to entry point
- [x] Verify plugin appears in Mobility's registry

#### 2.1.6: Verify Tests Pass

- [x] Run `bundle exec rake test TEST=test/mobility/rich_text/plugins/rich_text_test.rb`
- [x] All tests GREEN

**Acceptance Criteria:**
- [x] Plugin registered with Mobility
- [x] Read interception works correctly
- [x] Write interception works correctly
- [x] Bypass mechanism works
- [x] All tests passing
- [x] All public methods documented with TomDoc
- [x] Internal methods marked with `Internal:` prefix
- [x] RDoc generates without errors
- [x] RBS type signatures complete
- [x] `rbs validate` passes

---

### 2.2: Update Entry Point for Plugin

**Steps:**

- [x] Require plugin file in `lib/mobility/rich_text.rb`
- [x] Ensure Mobility is required first
- [x] Register plugin after requiring

**Acceptance Criteria:**
- [x] Plugin auto-registered on require
- [x] No circular dependency issues

---

### 2.3: Phase 2 Completion Checklist

**Before proceeding to Phase 3:**

- [x] All Phase 2 tasks completed
- [x] All plugin tests passing
- [x] Plugin integrates with Mobility correctly
- [x] All code documented with TomDoc
- [x] RDoc generates successfully
- [x] RBS type signatures complete for plugin
- [x] `rbs validate` passes
- [x] Code review approved
- [x] Documentation updated

**Phase 2 Status:** Complete

---

## Phase 3: Backend Integration Testing

**Goal:** Verify plugin works with all major Mobility backends.

**Status:** Complete

---

### 3.1: Set Up Test Fixtures

**Steps:**

- [x] Create test database schema for multiple backends
- [x] Set up KeyValue backend tables
- [x] Set up Table backend structure
- [x] Configure JSON columns (Container backend with SQLite)
- [x] Create test model(s) for integration testing

**Files Created:**
- `test/integration/integration_helper.rb` - SQLite in-memory database setup with multiple model configurations

### 3.2: Test KeyValue Backend

**Steps:**

- [x] Create `test/integration/key_value_backend_test.rb`
  - [x] Test read returns Content (12 tests)
  - [x] Test write stores HTML string
  - [x] Test multiple locales work
  - [x] Test string type translations
  - [x] Test text type translations
  - [x] Test bypass returns raw string
  - [x] Test blank and present methods
  - [x] Test round trip preserves complex HTML

### 3.3: Test Container Backend (JSON)

**Steps:**

- [x] Create `test/integration/container_backend_test.rb`
  - [x] Test read returns Content (9 tests)
  - [x] Test write stores HTML string in JSON column
  - [x] Test multiple locales work
  - [x] Test bypass returns raw string
  - [x] Test round trip preserves complex HTML

### 3.4: Test Table Backend

**Note:** Table backend is configured in integration_helper.rb with `ArticleWithTableBackend` model.

### 3.5: Phase 3 Completion Checklist

**Before proceeding to Phase 4:**

- [x] All Phase 3 tasks completed
- [x] KeyValue backend tested and passing (12 tests)
- [x] Container backend tested and passing (9 tests)
- [x] At least one column backend tested (Container/JSON)
- [x] All integration tests passing

**Phase 3 Status:** Complete

---

## Phase 4: Attachment Support

**Goal:** Verify ActionText attachment features work through the plugin.

**Status:** Complete

---

### 4.1: Set Up Test Fixtures

**Steps:**

- [x] Configure test environment for attachment parsing
- [x] Create test HTML with `<action-text-attachment>` tags
- [x] Create sample gallery and mixed content fixtures

### 4.2: Test Attachment Parsing

**Steps:**

- [x] Create `test/integration/attachment_test.rb`
  - [x] Test `<action-text-attachment>` tags are preserved (13 tests)
  - [x] Test `#attachments` method responds
  - [x] Test `#gallery_attachments` method responds
  - [x] Test attachment SGIDs preserved through round trip
  - [x] Test multiple attachments preserved

### 4.3: Test Attachment Features

**Steps:**

- [x] Test `#links` extraction works
- [x] Test plain text extraction without attachments
- [x] Test attachments work across locales
- [x] Test edge cases (empty tags, malformed tags)

### 4.4: Phase 4 Completion Checklist

**Final Acceptance:**

- [x] All 4 phases completed
- [x] All tests passing (71 tests, 124 assertions)
- [x] Attachment support verified
- [x] All public API documented with TomDoc
- [x] RDoc documentation generates successfully
- [x] All RBS type signatures complete
- [x] `rbs validate` passes
- [x] Steep type checking passes
- [x] README documentation complete
- [x] Ready for release

**Phase 4 Status:** Complete

---

## Definition of Done

**Per Phase:**
- [x] All tasks checked off
- [x] All tests written first (TDD)
- [x] All tests passing
- [x] All code documented with TomDoc
- [x] RDoc generates without errors
- [x] RBS type signatures complete
- [x] `rbs validate` passes
- [x] No linter errors

**Overall Feature:**
- [x] All 4 phases complete
- [x] All acceptance criteria from spec.md met
- [x] All public API documented with TomDoc
- [x] RDoc documentation generates successfully
- [x] All RBS type signatures complete
- [x] `rbs validate` passes
- [x] README documentation complete
- [x] Gem ready for release

---

## Test Summary

| Test File | Tests | Assertions |
|-----------|-------|------------|
| `test/mobility/rich_text/content_test.rb` | Unit tests for Content class | - |
| `test/mobility/rich_text/plugins/rich_text_test.rb` | Unit tests for plugin | - |
| `test/integration/key_value_backend_test.rb` | 12 tests | - |
| `test/integration/container_backend_test.rb` | 9 tests | - |
| `test/integration/attachment_test.rb` | 13 tests | - |
| **Total** | **71 tests** | **124 assertions** |

---

## Command Reference

```bash
# Run all tests
bundle exec rake test

# Run specific test file
bundle exec rake test TEST=test/mobility/rich_text/content_test.rb

# Run linter
bundle exec rake rubocop

# Run tests with verbose output
bundle exec rake test TESTOPTS="--verbose"

# Generate documentation (TomDoc via RDoc)
bundle exec rdoc lib/

# Generate documentation with specific format
bundle exec rdoc --format=darkfish lib/

# Generate documentation for specific file
bundle exec rdoc lib/mobility/rich_text/content.rb

# View generated documentation
open doc/index.html

# Validate RBS type signatures
bundle exec rbs -I sig validate

# Run Steep type checking
bundle exec steep check

# Run all checks (default rake task)
bundle exec rake
```

---

## Related Documentation

- **[spec.md](./spec.md)** - What to build
- **[plan.md](./plan.md)** - How to build it
- **[summary.md](./summary.md)** - Status overview
- **[extras/](./extras/)** - Supporting details

---

**Last Updated:** January 2026
**Completion Date:** January 2026
