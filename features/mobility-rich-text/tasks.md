# mobility-rich_text - Implementation Checklist

**Feature:** Mobility Rich Text Plugin
**Current Phase:** Phase 1 (Foundation)

> **Critical:** Follow phases IN ORDER. Write tests FIRST (TDD). Don't proceed to next phase until current phase is 100% complete with all tests passing.

---

## Progress Tracker

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Foundation | Not started | 0% |
| Phase 2: Plugin Core | Planned | 0% |
| Phase 3: Backend Integration | Planned | 0% |
| Phase 4: Attachment Support | Planned | 0% |

**Overall Completion:** Not started

---

## Phase 1: Foundation (Wrapper Class)

**Goal:** Create the Wrapper class that provides a consistent interface around ActionText::Content.

**Status:** Not Started

---

### 1.1: Create Wrapper Class

**Deliverables:**
- [ ] `lib/mobility/rich_text/wrapper.rb`
- [ ] `test/mobility/rich_text/wrapper_test.rb`

**Steps:**

#### 1.1.1: Write Tests First (TDD)

- [ ] Create `test/mobility/rich_text/wrapper_test.rb`
  - [ ] Test `#initialize` accepts HTML string
  - [ ] Test `#initialize` handles nil (converts to empty string)
  - [ ] Test `#initialize` handles empty string
  - [ ] Test `#to_s` returns rendered HTML
  - [ ] Test `#to_html` returns HTML string
  - [ ] Test `#to_plain_text` strips HTML tags
  - [ ] Test `#blank?` returns true for empty content
  - [ ] Test `#blank?` returns false for content with text
  - [ ] Test `#present?` is inverse of `#blank?`
  - [ ] Test `#to_action_text_content` returns ActionText::Content
  - [ ] Test `#==` with another Wrapper
  - [ ] Test `#==` with ActionText::Content
  - [ ] Test `#==` with String
  - [ ] Test delegation to ActionText::Content methods

#### 1.1.2: Implement Wrapper Class

- [ ] Create `lib/mobility/rich_text/wrapper.rb`
  - [ ] Add `initialize(html)` method
  - [ ] Add `to_s` method
  - [ ] Add `to_html` method
  - [ ] Add `to_plain_text` method
  - [ ] Add `blank?` method
  - [ ] Add `present?` method
  - [ ] Add `to_action_text_content` method
  - [ ] Add `==` comparison method
  - [ ] Add `delegate_missing_to :@content`

#### 1.1.3: Verify Tests Pass

- [ ] Run `bundle exec rake test TEST=test/mobility/rich_text/wrapper_test.rb`
- [ ] All tests GREEN
- [ ] Run `bundle exec rake rubocop`
- [ ] No style violations

**Acceptance Criteria:**
- [ ] Wrapper class exists at correct path
- [ ] All tests written first (TDD)
- [ ] All tests passing
- [ ] Handles nil and empty string gracefully
- [ ] Delegates unknown methods to ActionText::Content

---

### 1.2: Update Entry Point

**Deliverables:**
- [ ] Updated `lib/mobility/rich_text.rb`

**Steps:**

- [ ] Require ActionText dependency
- [ ] Require wrapper file
- [ ] Ensure proper load order

**Acceptance Criteria:**
- [ ] `require "mobility/rich_text"` loads all necessary files
- [ ] No load order errors

---

### 1.3: Phase 1 Completion Checklist

**Before proceeding to Phase 2:**

- [ ] All Phase 1 tasks completed
- [ ] All wrapper tests passing
- [ ] Code review approved (if applicable)
- [ ] Documentation updated (this file)
- [ ] No linter errors

**Phase 1 Status:** Not started → Complete (update when done)

---

## Phase 2: Plugin Core

**Goal:** Create the Mobility plugin with read/write interception.

**Status:** Planned (waiting for Phase 1)

---

### 2.1: Create Plugin Module

**Deliverables:**
- [ ] `lib/mobility/rich_text/plugins/rich_text.rb`
- [ ] `test/mobility/rich_text/plugins/rich_text_test.rb`

**Steps:**

#### 2.1.1: Write Tests First (TDD)

- [ ] Create `test/mobility/rich_text/plugins/rich_text_test.rb`
  - [ ] Test plugin registration with Mobility
  - [ ] Test plugin disabled by default
  - [ ] Test plugin enabled with `rich_text: true`
  - [ ] Test read returns Wrapper when enabled
  - [ ] Test read returns nil when value is nil
  - [ ] Test read returns raw string with `rich_text: false` option
  - [ ] Test write accepts String
  - [ ] Test write accepts ActionText::Content
  - [ ] Test write accepts Wrapper
  - [ ] Test write accepts nil
  - [ ] Test write normalizes to HTML string

#### 2.1.2: Implement Plugin Module

- [ ] Create `lib/mobility/rich_text/plugins/rich_text.rb`
  - [ ] Extend `Mobility::Plugin`
  - [ ] Set `default false`
  - [ ] Implement `included_hook`
  - [ ] Create `BackendMethods` module
  - [ ] Implement `read` method override
  - [ ] Implement `write` method override
  - [ ] Implement `normalize_value` private method

#### 2.1.3: Register Plugin

- [ ] Add `Mobility::Plugins.register_plugin(:rich_text, RichText)` to entry point
- [ ] Verify plugin appears in Mobility's registry

#### 2.1.4: Verify Tests Pass

- [ ] Run `bundle exec rake test TEST=test/mobility/rich_text/plugins/rich_text_test.rb`
- [ ] All tests GREEN

**Acceptance Criteria:**
- [ ] Plugin registered with Mobility
- [ ] Read interception works correctly
- [ ] Write interception works correctly
- [ ] Bypass mechanism works
- [ ] All tests passing

---

### 2.2: Update Entry Point for Plugin

**Steps:**

- [ ] Require plugin file in `lib/mobility/rich_text.rb`
- [ ] Ensure Mobility is required first
- [ ] Register plugin after requiring

**Acceptance Criteria:**
- [ ] Plugin auto-registered on require
- [ ] No circular dependency issues

---

### 2.3: Phase 2 Completion Checklist

**Before proceeding to Phase 3:**

- [ ] All Phase 2 tasks completed
- [ ] All plugin tests passing
- [ ] Plugin integrates with Mobility correctly
- [ ] Code review approved
- [ ] Documentation updated

**Phase 2 Status:** Planned → Complete (update when done)

---

## Phase 3: Backend Integration Testing

**Goal:** Verify plugin works with all major Mobility backends.

**Status:** Planned (waiting for Phase 2)

---

### 3.1: Set Up Test Fixtures

**Steps:**

- [ ] Create test database schema for multiple backends
- [ ] Set up KeyValue backend tables
- [ ] Set up Table backend structure
- [ ] Configure JSON/JSONB columns (if PostgreSQL available)
- [ ] Create test model(s) for integration testing

### 3.2: Test KeyValue Backend

**Steps:**

- [ ] Create `test/integration/key_value_backend_test.rb`
  - [ ] Test read returns Wrapper
  - [ ] Test write stores HTML string
  - [ ] Test multiple locales work
  - [ ] Test string type translations
  - [ ] Test text type translations

### 3.3: Test Table Backend

**Steps:**

- [ ] Create `test/integration/table_backend_test.rb`
  - [ ] Test read returns Wrapper
  - [ ] Test write stores HTML string
  - [ ] Test multiple locales work

### 3.4: Test JSON/JSONB Backend

**Steps:**

- [ ] Create `test/integration/json_backend_test.rb` (if applicable)
  - [ ] Test read returns Wrapper
  - [ ] Test write stores HTML string
  - [ ] Test multiple locales work

### 3.5: Test Hstore Backend

**Steps:**

- [ ] Create `test/integration/hstore_backend_test.rb` (if PostgreSQL available)
  - [ ] Test read returns Wrapper
  - [ ] Test write stores HTML string

### 3.6: Phase 3 Completion Checklist

**Before proceeding to Phase 4:**

- [ ] All Phase 3 tasks completed
- [ ] KeyValue backend tested and passing
- [ ] Table backend tested and passing
- [ ] At least one column backend tested (JSON/JSONB/Hstore)
- [ ] All integration tests passing

**Phase 3 Status:** Planned → Complete (update when done)

---

## Phase 4: Attachment Support

**Goal:** Verify ActionText attachment features work through the plugin.

**Status:** Planned (waiting for Phase 3)

---

### 4.1: Set Up ActiveStorage Fixtures

**Steps:**

- [ ] Configure ActiveStorage for test environment
- [ ] Create test fixtures for blobs
- [ ] Create test attachments with SGIDs

### 4.2: Test Attachment Parsing

**Steps:**

- [ ] Create `test/integration/attachment_test.rb`
  - [ ] Test `<action-text-attachment>` tags are preserved
  - [ ] Test `#attachments` returns attachment list
  - [ ] Test `#gallery_attachments` groups attachments
  - [ ] Test attachment SGIDs are valid

### 4.3: Test Attachment Rendering

**Steps:**

- [ ] Test `#render_attachments` works with block
- [ ] Test attachments render in views
- [ ] Test missing attachments handled gracefully

### 4.4: Phase 4 Completion Checklist

**Final Acceptance:**

- [ ] All 4 phases completed
- [ ] All tests passing
- [ ] Attachment support verified
- [ ] Documentation complete
- [ ] Ready for release

**Phase 4 Status:** Planned → Complete (update when done)

---

## Definition of Done

**Per Phase:**
- [ ] All tasks checked off
- [ ] All tests written first (TDD)
- [ ] All tests passing
- [ ] No linter errors

**Overall Feature:**
- [ ] All 4 phases complete
- [ ] All acceptance criteria from spec.md met
- [ ] README documentation complete
- [ ] Gem ready for release

---

## Command Reference

```bash
# Run all tests
bundle exec rake test

# Run specific test file
bundle exec rake test TEST=test/mobility/rich_text/wrapper_test.rb

# Run linter
bundle exec rake rubocop

# Run tests with verbose output
bundle exec rake test TESTOPTS="--verbose"
```

---

## Related Documentation

- **[spec.md](./spec.md)** - What to build
- **[plan.md](./plan.md)** - How to build it
- **[summary.md](./summary.md)** - Status overview
- **[extras/](./extras/)** - Supporting details

---

**Next Review:** After each phase completion
