import Lake
open Lake DSL

package «hep_lean» {}

-- # -- Optional inclusion for LeanCopilot
-- #moreLinkArgs = ["-L./.lake/packages/LeanCopilot/.lake/build/lib", "-lctranslate2"]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.7.0"

require «doc-gen4» from git
  "https://github.com/leanprover/doc-gen4" @ "a34d3c1f7b72654c08abe5741d94794db40dbb2e"

@[default_target]
lean_lib HepLean where


-- # -- Optional inclusion of llm. Needed for `openAI_doc_check`
-- #[[require]]
-- #name = "llm"
-- #git = "https://github.com/leanprover-community/llm"
-- #rev = "main"

-- # -- Optional inclusion of tryAtEachStep
-- #[[require]]
-- #name = "tryAtEachStep"
-- #git = "https://github.com/dwrensha/tryAtEachStep"
-- #rev = "main"

-- # -- Optional inclusion of LeanCopilot
-- #[[require]]
-- #name = "LeanCopilot"
-- #git = "https://github.com/lean-dojo/LeanCopilot.git"
-- #rev = "v1.4.1"

-- # lean_exe commands defined specifically for HepLean.

-- [[lean_exe]]
-- name = "check_file_imports"
-- srcDir = "scripts"

-- [[lean_exe]]
-- name = "type_former_lint"
-- srcDir = "scripts"

-- [[lean_exe]]
-- name = "hepLean_style_lint"
-- srcDir = "scripts"

-- [[lean_exe]]
-- name = "find_TODOs"
-- srcDir = "scripts"

-- [[lean_exe]]
-- name = "mathlib_textLint_on_hepLean"
-- srcDir = "scripts"

-- [[lean_exe]]
-- name = "stats"
-- srcDir = "scripts"

-- [[lean_exe]]
-- name = "free_simps"
-- srcDir = "scripts/MetaPrograms"

-- [[lean_exe]]
-- name = "informal"
-- supportInterpreter = true
-- srcDir = "scripts/MetaPrograms"

-- # -- Optional inclusion of openAI_doc_check. Needs `llm` above.
-- #[[lean_exe]]
-- #name = "openAI_doc_check"
-- #srcDir = "scripts"
