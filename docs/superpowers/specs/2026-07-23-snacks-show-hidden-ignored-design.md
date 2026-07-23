# Snacks Hidden and Git-Ignored Files Design

## Goal

Make hidden files and files ignored by Git visible by default in the Snacks Explorer and in picker file/grep sources.

## Scope

- Update the Snacks configuration in `lua/plugins/editor/snacks.lua`.
- Configure the picker `explorer` source with `hidden = true` and `ignored = true`.
- Configure the picker `files` and `grep` sources with `hidden = true` and `ignored = true`.
- Preserve the current Explorer layout, picker layouts, keymaps, and all unrelated configuration.

## Approaches

1. Configure each affected source explicitly. This is the recommended approach because the behavior is visible at each source and avoids changing unrelated picker sources.
2. Set broader picker defaults. This is shorter but couples unrelated sources to the same visibility policy and depends more heavily on Snacks global-default behavior.

## Design

Use explicit per-source options under `opts.picker.sources` for `files`, `grep`, and `explorer`. Each source will set `hidden = true` and `ignored = true`; the existing top-level Explorer options and right-sidebar layouts will remain unchanged.

## Validation

- Parse the edited Lua file with Neovim in headless mode.
- Run the repository's existing test command if available and report its result.
- Confirm the diff contains only the intended configuration and this design document.
