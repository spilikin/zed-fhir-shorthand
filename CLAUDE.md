# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Zed](https://zed.dev) language extension for **FHIR Shorthand (FSH)** — the
HL7 DSL for authoring FHIR profiles, extensions, value sets, and Implementation
Guide artifacts (`.fsh` files, compiled by SUSHI / `fsh-sushi`).

It is a **grammar-only extension**: declarative TOML + Tree-sitter query files.
No Rust code, no language server. Live diagnostics/completion are out of scope
unless a language server is added later (see "Adding a language server").

## Two repositories

This project spans **two sibling repos**:

| Path | What |
|---|---|
| `zed-fhir-shorthand/` (this repo) | the Zed extension — manifest + language config + `.scm` queries |
| `../tree-sitter-fsh/` | the **Tree-sitter grammar**, hand-authored for this project |

The grammar is *not* a third-party dependency. It was written from scratch by
porting SUSHI's official ANTLR grammar (`FSH.g4` / `FSHLexer.g4`, `master`
branch — FSH 3.0.0). The earlier third-party grammar (`mgramigna/tree-sitter-fsh`)
was abandoned: it had no keyword-boundary handling (it mis-tokenised identifiers
like `MetaSourceProfile` as `MetaSource` + `Profile`) and predated FSH 3.0.0.

## Architecture

1. **`extension.toml`** — the manifest. `[grammars.fsh]` points at the
   `tree-sitter-fsh` repo by URL + commit `rev`. In dev this is a local
   `file://` path; Zed clones it at `rev` and compiles `src/parser.c` to WASM.
2. **`languages/fsh/config.toml`** — declares the `FSH` language: `.fsh` file
   association, comments, auto-close, `tab_size`. `grammar = "fsh"` must match
   the `[grammars.fsh]` key in `extension.toml`.
3. **`languages/fsh/*.scm`** — Tree-sitter [queries](https://zed.dev/docs/extensions/languages):
   `highlights.scm` and `outline.scm`. (No `brackets.scm` — the grammar has no
   standalone bracket nodes; auto-close is handled by `config.toml`.)

The critical coupling: the `.scm` files reference **node names from
`tree-sitter-fsh/grammar.js`** (`profile`, `card_rule`, `caret_path`,
`ruleset_reference`, the `name`/`path`/`value`/`binding` fields, …). A query
referencing a node the grammar doesn't define fails to compile, which aborts
loading the **entire language**. The `rev` in `extension.toml` and the `.scm`
files are a matched set — when the grammar changes, regenerate it, commit, bump
`rev`, and update the queries together.

`config.toml` forces `tab_size = 2` / `hard_tabs = false`: FSH derives a rule's
path context from indentation and SUSHI rejects anything not in 2-space
increments, so the extension must not inherit a 4-space editor default.

## The grammar (`../tree-sitter-fsh`)

A faithful port of the ANTLR grammar with one structural improvement:
**identifier-like tokens use maximal munch** (`sequence` is one greedy
non-whitespace token, not char-by-char), so a keyword can never be matched
inside a longer identifier. Other deliberate choices, documented in the header
of `grammar.js`:

- Declaration keywords are the literal `Word:` (colon included) — bare `Word`
  is never a keyword. Whitespace is required *after* the colon.
- `Reference(...)` / `Canonical(...)` / `CodeableReference(...)` and parameterised
  RuleSet references are single tokens (ANTLR uses lexer modes; we don't).
- The comma is excluded from identifier tokens so `Context:` / `Characteristics:`
  comma-lists parse without lexer modes.
- ANTLR's `name`/`path` re-admit every keyword (its lexer is stateless);
  tree-sitter's lexer is parser-state-aware, so they don't need to.

Regenerating the grammar after editing `grammar.js`:

```sh
cd ../tree-sitter-fsh
npm run generate                              # writes src/parser.c
./node_modules/.bin/tree-sitter parse examples/sample.fsh   # check parse tree
./node_modules/.bin/tree-sitter query ../zed-fhir-shorthand/languages/fsh/highlights.scm examples/sample.fsh
git commit -am "..."                          # then bump rev in extension.toml
```

`tree-sitter generate` errors on unresolved GLR conflicts — resolve each by a
`conflicts:` entry or a `prec()`/`prec.dynamic()`, never by guessing.

## Development workflow

1. **Install:** Zed command palette → `zed: install dev extension` → select
   this repo. Zed clones `tree-sitter-fsh` at `rev` and compiles it.
2. **Test:** open a `.fsh` file (`examples/patient.fsh`); check highlighting and
   the outline panel (`cmd-shift-o`).
3. **Reload after editing `.scm`:** `zed: reload extensions`.
4. **After changing the grammar:** regenerate + commit in `tree-sitter-fsh`,
   bump `rev` in `extension.toml`, then re-run *Install Dev Extension* (a plain
   reload won't re-fetch the grammar).
5. **Troubleshooting:** `zed: open log`, or relaunch `zed --foreground`.

## Conventions / gotchas

- `schema_version = 1` in `extension.toml`.
- A `.scm` query referencing a node *type* the grammar doesn't expose aborts the
  whole language — symptom is zero highlighting plus `failed to load language
  FSH` in `zed: open log`. Validate queries with `tree-sitter query` before
  installing.
- Unknown highlight *capture names* (`@foo`) are silently ignored by Zed; Zed
  resolves dotted names by longest-prefix fallback (`@string.special.symbol` →
  `string.special` → `string`).
- The grammar generates with Tree-sitter ABI 14 (no `tree-sitter.json`); Zed
  compiles that fine.
- **Publishing:** the Zed registry needs the grammar at a *public* git URL.
  Before publishing the extension, push `tree-sitter-fsh` to a public repo and
  replace the `file://` URL in `[grammars.fsh]` with its `https` URL.

## Highlighting design

`highlights.scm` maps FSH onto modern Tree-sitter captures: entity declaration
keywords → `@keyword`; the defined name → `@type` (Profile/Extension/Logical/
Resource/ValueSet/CodeSystem/Invariant/Mapping), `@constant` (Instance/Alias),
or `@function` (RuleSet, matched at both definition and `insert` call sites);
type references (`Parent:`, `only`, `from`, `Reference(...)`) → `@type`; element
paths → `@property`; codes (`#code`) → `@string.special.symbol`; flags (`MS`,
`?!`) → `@attribute`; binding strengths → `@constant.builtin`; the `*` rule
marker → `@punctuation.list_marker`.

## Adding a language server (future)

No standalone FSH language server is published, so LSP support would require
shipping/wrapping one (e.g. building on the `FHIR/vscode-fsh` server or SUSHI).
That converts this into a **Rust extension**: add `Cargo.toml` + `src/lib.rs`
against the `zed_extension_api` crate, register a `[language_servers.*]` block
in `extension.toml`, and implement `language_server_command`.
