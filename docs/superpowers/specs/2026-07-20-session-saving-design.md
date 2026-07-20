# Project Session Saving Design

## Goal

Add automatic project session persistence to Neovim without introducing another
plugin dependency.

## Behavior

- Sessions are stored in Neovim's state directory, under a dedicated `sessions`
  directory.
- Each session is keyed by the absolute current working directory, encoded into
  a filesystem-safe filename.
- On startup, restore the session only when Neovim was launched without file
  arguments and a saved session exists for the current working directory.
- On exit, save the current session when the current working directory is a
  valid project/session location.
- Do not create sessions for special working directories such as `/` or the
  user's home directory.
- Expose explicit `:SessionSave`, `:SessionRestore`, and `:SessionDelete`
  commands.
- Add leader mappings for save, restore, and delete, with descriptions visible
  in which-key.

## Architecture

Create a focused `lua/config/session.lua` module that owns session paths and
operations:

- `session_path()` returns the session file for the current directory or nil
  when the directory is not eligible.
- `save()` creates the session directory and writes the session with
  `:mksession!`.
- `restore()` sources the current directory's session if it exists.
- `delete()` removes the current directory's session if it exists.
- `setup()` registers commands and autocmds, and performs conditional startup
  restoration.

Load the module from `init.lua` after options and keymaps are configured. The
module's autocmds use `VimEnter` for restore and `VimLeavePre` for save, with
guards that prevent restore when command-line file arguments are present.

## Error handling

- File-system failures should be reported with `vim.notify()` at error level;
  session failures must not prevent Neovim from starting or exiting.
- Missing sessions are a no-op for restore and delete.
- Session operations use the escaped absolute working directory as their key,
  so unrelated projects cannot collide.

## Testing

Add a Lua spec that loads the module with mocked Neovim APIs where necessary
and verifies:

1. eligible directories produce stable, distinct session paths;
2. save creates the directory and invokes `mksession!` with the generated path;
3. restore sources an existing session and is a no-op when absent; and
4. startup restoration is skipped when file arguments are present.

Also run the existing headless startup/test commands and validate the final
working-tree diff.
