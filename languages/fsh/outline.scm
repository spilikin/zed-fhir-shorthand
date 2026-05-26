; Code outline (symbol list) for FSH definitions.
; @item = whole entity, @name = symbol name, @context = entity keyword.

(alias       "Alias:" @context       name: (name) @name) @item
(profile     "Profile:" @context     name: (name) @name) @item
(extension   "Extension:" @context   name: (name) @name) @item
(logical     "Logical:" @context     name: (name) @name) @item
(resource    "Resource:" @context    name: (name) @name) @item
(instance    "Instance:" @context    name: (name) @name) @item
(invariant   "Invariant:" @context   name: (name) @name) @item
(value_set   "ValueSet:" @context    name: (name) @name) @item
(code_system "CodeSystem:" @context  name: (name) @name) @item
(mapping     "Mapping:" @context     name: (name) @name) @item
(rule_set    "RuleSet:" @context     name: (ruleset_reference) @name) @item
