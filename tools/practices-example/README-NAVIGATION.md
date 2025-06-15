# 🧭 Best Practices Navigation Guide

## Using This Practices Repository

### For AI Assistants
When working on this project, prioritize:

1. **Current practices** over deprecated ones
2. **Recent patterns** (last 2 months) for active development
3. **Established patterns** for stable, proven approaches
4. **Category-specific practices** for domain expertise

### For Developers
- Check `current-practices.md` before starting new work
- Review `deprecated-practices.md` to avoid outdated patterns  
- Use `evolution-timeline.md` to understand design decisions
- Browse categories for domain-specific guidance

### For Code Reviews
Focus on:
- Are we following current best practices?
- Are we avoiding deprecated patterns?
- Do new approaches align with recent successful implementations?

### Regenerating Practices
```bash
# Regenerate with default settings
./extract-practices.sh

# Analyze longer period with higher significance
./extract-practices.sh . -m 12 -s 4

# Clean rebuild in custom location  
./extract-practices.sh . -o team-practices --clean
```

## File Organization

```
practices/
├── index.md                    # Start here - master index
├── current-practices.md        # What to do now
├── deprecated-practices.md     # What to avoid
├── evolution-timeline.md       # How we got here
├── by-category/               # Domain-specific practices
└── by-recency/               # Time-based organization
```

---
*Part of the Git-Based Best Practices Extraction System*
