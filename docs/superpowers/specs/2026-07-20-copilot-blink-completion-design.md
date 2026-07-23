# GitHub Copilot Blink Completion Design

## Goal

Add GitHub Copilot code suggestions to the existing `blink.cmp` completion menu without replacing LSP, path, snippet, buffer, or CodeCompanion behavior.

## Architecture

`zbirenbaum/copilot.lua` provides the GitHub Copilot LSP client and authentication. `fang2hou/blink-copilot` adapts that client to the existing `blink.cmp` source API. Copilot's native ghost-text and panel UIs will be disabled so Blink remains the single completion presentation layer.

The integration will load on `InsertEnter`, use the existing Blink keymaps, and add `copilot` after the current completion sources with a positive score offset. CodeCompanion will continue using its existing Copilot adapter independently for chat and inline transformations.

## Configuration and authentication

The Copilot plugin will expose the `:Copilot` command and use its normal authentication flow. The user can run `:Copilot auth` after installation. No credentials will be stored in this repository.

## Testing

The plugin graph test will require both Copilot plugins. The completion test will verify that the Copilot source is present and the legacy native suggestion UI is not added. Headless startup and the full test suite will be run after the change.

## Scope

This change does not add new keybindings, change existing completion acceptance behavior, alter CodeCompanion adapters, or enable next-edit suggestions.
