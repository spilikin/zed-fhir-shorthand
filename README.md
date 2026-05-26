# FHIR Shorthand for Zed

A [Zed](https://zed.dev) extension that adds language support for
[FHIR Shorthand (FSH)](https://hl7.org/fhir/uv/shorthand/) — the domain-specific
language for authoring HL7® FHIR® profiles, extensions, value sets, and other
Implementation Guide artifacts.

## Features

- Syntax highlighting for `.fsh` files
- Code outline (Profiles, Extensions, Instances, ValueSets, CodeSystems, …)

It is a **grammar-only** extension: highlighting and outline come from a
purpose-built [Tree-sitter grammar](../tree-sitter-fsh) — a port of SUSHI's
official ANTLR grammar for FSH 3.0.0. There is no language server yet, so live
diagnostics and completion are not provided — run
[SUSHI](https://github.com/FHIR/sushi) (`fsh-sushi`) for compilation and error
checking.

## Install (development)

1. Open Zed.
2. Run **`zed: install dev extension`** from the command palette and select this
   directory.
3. Open a `.fsh` file (e.g. [`examples/patient.fsh`](examples/patient.fsh)).

Zed downloads and compiles the Tree-sitter grammar on install. Edits to the
`.scm` query files are picked up after **`zed: reload extensions`**.

## License

[MIT](LICENSE) © 2026 Sergej Suskov
