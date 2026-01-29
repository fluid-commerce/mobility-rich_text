# mobility-rich_text Feature

**Status:** Complete (71 tests, 124 assertions)

A Mobility plugin that wraps string values from any backend with `ActionText::Content`, enabling rich text editing for translated content without separate ActionText storage.

---

## What Is This?

This gem provides a Mobility plugin that intercepts reads and writes on translated attributes, automatically wrapping string values with ActionText's rich text capabilities. Unlike `mobility-actiontext` (which stores rich text in separate ActionText records), this plugin keeps translations in your existing backend while providing full ActionText features.

---

## File Structure

```
features/mobility-rich-text/
├── README.md              # This file - navigation guide
├── spec.md                # Business & technical specification
├── plan.md                # Architecture & design decisions
├── tasks.md               # Phase-by-phase implementation checklist
├── summary.md             # Executive status overview
└── extras/
    └── README.md          # Guidelines for supplementary docs
```

---

## I Want To...

### Understand the Feature

| Goal | Document |
|------|----------|
| Learn what this gem does | [spec.md](./spec.md) - Business Context |
| See the API and usage | [spec.md](./spec.md) - API Specification |
| Understand requirements | [spec.md](./spec.md) - Functional Requirements |

### Understand the Implementation

| Goal | Document |
|------|----------|
| See architecture overview | [plan.md](./plan.md) - Architecture Overview |
| Understand design decisions | [plan.md](./plan.md) - Key Design Decisions |
| See code structure | [plan.md](./plan.md) - File Structure |

### Track Progress

| Goal | Document |
|------|----------|
| See current status | [summary.md](./summary.md) - At a Glance |
| View implementation tasks | [tasks.md](./tasks.md) - Progress Tracker |
| Check completion criteria | [tasks.md](./tasks.md) - Definition of Done |

### Find Supplementary Info

| Goal | Document |
|------|----------|
| Research notes | [extras/](./extras/) |
| Detailed investigations | [extras/README.md](./extras/README.md) |

---

## Quick Reference

| Topic | Location |
|-------|----------|
| **Plugin configuration** | `translates :content, backend: :key_value, rich_text: true` |
| **Content class** | `lib/mobility/rich_text/content.rb` |
| **Plugin module** | `lib/mobility/rich_text/plugins/rich_text.rb` |
| **Entry point** | `lib/mobility/rich_text.rb` |
| **Unit tests** | `test/mobility/rich_text/` |
| **Integration tests** | `test/integration/` |

---

## Key Differentiator

**mobility-actiontext** stores rich text in separate `ActionText::RichText` records per locale.

**mobility-rich_text** (this gem) wraps existing translated strings with `ActionText::Content`, keeping your data in your chosen backend while gaining ActionText features.

---

## Related Documentation

- **[Mobility documentation](https://github.com/shioyama/mobility)**
- **[ActionText documentation](https://edgeguides.rubyonrails.org/action_text_overview.html)**
