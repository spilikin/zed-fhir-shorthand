# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Zed](https://zed.dev) language extension for **FHIR Shorthand (FSH)** — the
HL7 DSL for authoring FHIR profiles, extensions, value sets, and Implementation
Guide artifacts (`.fsh` files, compiled by SUSHI / `fsh-sushi`).

It is a **grammar-only extension**: purely declarative TOML + Tree-sitter query
files. There is no Rust code, no WASM build, and no language server. Live
diagnostics/completion are out of scope unless a language server is added later
(see "Adding a language server").

## Architecture

The extension wires three things together:

1. **`extension.toml`** — the manifest. `[grammars.fsh]` points at the external
   Tree-sitter grammar repo (`mgramigna/tree-sitter-fsh`) pinned to a commit
   `rev`. The grammar is **not vendored** — Zed clones and compiles it to WASM at
   install time.
2. **`languages/fsh/config.toml`** — declares the `FSH` language: `.fsh` file
   association, comment syntax, brackets/auto-close. Its `grammar = "fsh"` field
   must match the `[grammars.fsh]` key in `extension.toml`.
3. **`languages/fsh/*.scm`** — Tree-sitter [queries](https://zed.dev/docs/extensions/languages):
   `highlights.scm`, `brackets.scm`, `outline.scm`. They run against the parse
   tree the grammar produces.

The critical coupling: the `.scm` files reference **node names from the upstream
grammar's `grammar.js`** (`profile`, `extension`, `name`, `sd_metadata`,
`alias_name`, `rule_set_reference`, `param_rule_set_reference`, etc.). A query
that references a node the grammar doesn't define fails to load and silently
disables that query file. The `rev` in `extension.toml` and the `.scm` files are
a matched set — bump them together.

`highlights.scm` is kept in sync with the grammar's own `queries/highlights.scm`.
`outline.scm` uses Zed's capture convention: `@item` (whole symbol), `@name`
(symbol name), `@context` (extra label, here the entity keyword).

## Development workflow

There is no CLI build or test step. Iterate inside Zed:

1. **Install:** command palette → `zed: install dev extension` → select this
   repo's root directory. Zed downloads + compiles the grammar.
2. **Test:** open a `.fsh` file (use `examples/patient.fsh`); check highlighting
   and the outline panel.
3. **Reload after edits:** command palette → `zed: reload extensions`. Editing
   `.scm` query files only needs a reload; changing the grammar `rev` requires a
   full reinstall so Zed re-fetches and recompiles.

To inspect or debug the grammar's node names (needed when writing/fixing
queries), clone the grammar at the pinned `rev` and use the `tree-sitter` CLI:

```sh
git clone https://github.com/mgramigna/tree-sitter-fsh && cd tree-sitter-fsh
git checkout <rev-from-extension.toml>
tree-sitter generate && tree-sitter parse path/to/file.fsh   # shows the parse tree
```

## Conventions / gotchas

- `schema_version = 1` in `extension.toml` — current Zed extension schema.
- The grammar field is `rev` (a commit SHA), not a branch name.
- FSH has **no curly-brace constructs** — only `(...)` and `[...]`. Do not add
  `{`/`}` to `brackets.scm` or `config.toml`.
- Unknown highlight capture names are ignored by Zed (no error); a query that
  references a missing **node** breaks the whole file. Prefer node names already
  proven by the upstream `highlights.scm`.
- FSH comments are both `//` (line) and `/* */` (block) — the grammar surfaces
  both as a single `fsh_comment` node.

## Adding a language server (future)

No standalone FSH language server is published, so LSP support would require
shipping/wrapping one (e.g. building on the `FHIR/vscode-fsh` server or SUSHI).
That converts this into a **Rust extension**: add `Cargo.toml` +
`src/lib.rs` against the `zed_extension_api` crate, register a
`[language_servers.*]` block in `extension.toml`, and implement
`language_server_command`.
