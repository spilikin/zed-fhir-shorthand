; highlights.scm — FHIR Shorthand (FSH 3.0.0)
; Written against the purpose-built tree-sitter-fsh grammar pinned in
; extension.toml. Maps FSH constructs onto conventional Tree-sitter captures
; (Zed resolves dotted names with prefix fallback).

; --- Comments --------------------------------------------------------------
(comment) @comment

; --- Keywords --------------------------------------------------------------
; Entity declarations (`class`/`type`-like)
[
  "Alias:"
  "Profile:"
  "Extension:"
  "Logical:"
  "Resource:"
  "Instance:"
  "Invariant:"
  "ValueSet:"
  "CodeSystem:"
  "Mapping:"
  "RuleSet:"
] @keyword

; Metadata-header fields
[
  "Parent:"
  "Id:"
  "Title:"
  "Description:"
  "Expression:"
  "XPath:"
  "Severity:"
  "InstanceOf:"
  "Usage:"
  "Source:"
  "Target:"
  "Context:"
  "Characteristics:"
] @keyword

; Rule keywords
[
  "from"
  "contains"
  "named"
  "and"
  "only"
  "or"
  "obeys"
  "insert"
  "contentReference"
  "include"
  "exclude"
  "codes"
  "where"
  "system"
  "valueset"
] @keyword

(exactly) @keyword

; --- Operators & punctuation ----------------------------------------------
[ "=" "->" ] @operator
"*" @punctuation.list_marker
[ ":" "," ] @punctuation.delimiter

; --- Definitions: the name each entity introduces -------------------------
(profile     name: (name) @type)
(extension   name: (name) @type)
(logical     name: (name) @type)
(resource    name: (name) @type)
(value_set   name: (name) @type)
(code_system name: (name) @type)
(invariant   name: (name) @type)
(mapping     name: (name) @type)
(instance    name: (name) @constant)
(alias       name: (name) @constant)
(rule_set    name: (ruleset_reference) @function)
(insert_rule      ruleset: (ruleset_reference) @function)
(code_insert_rule ruleset: (ruleset_reference) @function)

; --- References to other definitions --------------------------------------
(parent          value: (name) @type)
(instance_of     value: (name) @type)
(source          value: (name) @type)
(value_set_rule  binding: (name) @type)
(vs_from_system  system: (name) @type)
(vs_from_valueset binding: (name) @type)
(obeys_rule (name) @type)
(target_type (name) @type)
[
  (reference)
  (codeable_reference)
  (canonical)
] @type

; --- Element paths (object-member-like) -----------------------------------
(path) @property
(caret_path) @property
(item (name) @property)
(vs_filter_definition (name) @property)

; --- Literals --------------------------------------------------------------
[ (string) (multiline_string) ] @string
(code) @string.special.symbol
[ "true" "false" ] @boolean
[ (number) (datetime) (time) (cardinality) ] @number
(unit) @string.special
(regex) @string.regex
(strength) @constant.builtin
(flag) @attribute
