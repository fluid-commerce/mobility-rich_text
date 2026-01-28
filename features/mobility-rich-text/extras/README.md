# mobility-rich_text Extras - Supporting Documentation

This directory contains detailed supporting documentation that supplements the standard documentation files.

---

## Purpose

The `extras/` directory is for:
- **Research notes** - Technical investigations into ActionText internals
- **Backend compatibility matrix** - Detailed testing results per backend
- **Design proposals** - Alternative approaches considered
- **Migration guides** - How to migrate from other solutions
- **Decision logs** - Detailed rationale for architectural choices

---

## Guidelines for Extras

### When to Add a File

Add a document to `extras/` when:
- It provides valuable context but isn't required reading
- It documents a decision or investigation in detail
- It's a one-time evaluation or proposal
- It tracks compatibility testing results

### Naming Convention

Use descriptive names that explain the content:
- `actiontext-internals-research.md` - Research on how ActionText works
- `backend-compatibility-matrix.md` - Test results for all backends
- `migration-from-mobility-actiontext.md` - Guide for switching gems
- `decisions-wrapper-class.md` - Why we created the Wrapper class

### What NOT to Put Here

Don't put these in `extras/`:
- Core requirements → goes in `spec.md`
- Architecture decisions → goes in `plan.md`
- Implementation tasks → goes in `tasks.md`
- Status updates → goes in `summary.md`

---

## Potential Extras Documents

As implementation progresses, consider adding:

### 1. ActionText Internals Research

**Filename:** `actiontext-internals-research.md`

**Purpose:** Document how ActionText::Content works internally

**Contents:**
- How `<action-text-attachment>` tags are parsed
- SGID lookup mechanism
- Rendering pipeline
- Sanitization behavior

### 2. Backend Compatibility Matrix

**Filename:** `backend-compatibility-matrix.md`

**Purpose:** Detailed compatibility testing results

**Contents:**
- Test results for each Mobility backend
- Known limitations per backend
- Performance characteristics
- Edge cases discovered

### 3. Migration from mobility-actiontext

**Filename:** `migration-from-mobility-actiontext.md`

**Purpose:** Guide for users switching from mobility-actiontext

**Contents:**
- Feature comparison
- Data migration steps
- Configuration changes
- Potential gotchas

---

## Current Contents

This directory currently contains:
- `README.md` - This file (guidelines for extras)

Additional files will be added as the implementation progresses and research is conducted.

---

## Related Documentation

### Standard Files (Required Reading)
- **[../README.md](../README.md)** - Navigation guide
- **[../spec.md](../spec.md)** - Requirements
- **[../plan.md](../plan.md)** - Architecture
- **[../tasks.md](../tasks.md)** - Implementation
- **[../summary.md](../summary.md)** - Status

### This Directory
- Supporting documentation for deep dives
- Not required for implementation
- Valuable context when available

---

**Purpose:** Comprehensive but optional documentation
**Audience:** Developers needing detailed context
**When to Read:** When you need deep background or specific guidance
