# Content Engineering Contract

Scope: `game/content/**`

This area contains authored gameplay data/resources when real content begins.

## Rules

- Content describes data; it does not become hidden runtime orchestration.
- Prefer typed custom Resources for structured authored data where appropriate.
- Content IDs must be stable once referenced by saves or other durable content.
- References between content entries should be explicit and validated.
- Do not duplicate canonical gameplay formulas inside content files and scripts.
- Do not create fake historical/runtime data solely for presentation.
- Add validation when content volume becomes large enough that manual inspection is unreliable.
- Player-facing terminology follows `docs/design/vocabulary.md`.
- Content files are not evidence that a runtime feature is complete; `docs/state.md` remains implementation truth.
