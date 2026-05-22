; Code outline (symbol list) for FSH definitions.
; Captures: @item = whole entity, @name = symbol name, @context = entity keyword.

(alias
  "Alias" @context
  (alias_name) @name) @item

(profile
  "Profile" @context
  (name) @name) @item

(extension
  "Extension" @context
  (name) @name) @item

(invariant
  "Invariant" @context
  (name) @name) @item

(instance
  "Instance" @context
  (name) @name) @item

(valueset
  "ValueSet" @context
  (name) @name) @item

(codesystem
  "CodeSystem" @context
  (name) @name) @item

(mapping
  "Mapping" @context
  (name) @name) @item

(logical
  "Logical" @context
  (name) @name) @item

(resource
  "Resource" @context
  (name) @name) @item

(rule_set
  "RuleSet" @context
  (rule_set_reference) @name) @item

(param_rule_set
  "RuleSet" @context
  (param_rule_set_reference) @name) @item
