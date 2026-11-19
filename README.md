# EditorBookmarks

EditorBookmarks is a Linux command-line tool for bookmarking and opening text files easily. Save a file’s path under a short name, then type `eb <name>` from any directory to open it in your preferred editor. That saves you from typing the full path or changing folders first. You can also search your bookmarks if you forget a name.

```bash
eb -a mango ~/.config/mango/config.conf
eb mango
```

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Get the source files](#get-the-source-files)
  - [Run the installer](#run-the-installer)
  - [Make eb available on PATH](#make-eb-available-on-path)
  - [Alias alternative](#alias-alternative)
- [Usage](#usage)
  - [Create your first bookmark](#create-your-first-bookmark)
  - [Add a file by relative path](#add-a-file-by-relative-path)
  - [Command reference](#command-reference)
  - [Bookmark names and paths](#bookmark-names-and-paths)
  - [Search and output](#search-and-output)
- [Shell completion](#shell-completion)
- [Editors and wrappers](#editors-and-wrappers)
  - [Edit a protected file with sudo](#edit-a-protected-file-with-sudo)
- [File locations](#file-locations)
  - [XDG directory overrides](#xdg-directory-overrides)
  - [Database and recovery](#database-and-recovery)
- [Updating](#updating)
- [Uninstallation](#uninstallation)
- [Licence](#licence)

## Requirements

- Linux with Bash 4.3 or later.
- Standard Linux command-line tools, including GNU Coreutils, `sed`, `awk`
  and `flock` from util-linux.
- A text editor such as Micro, Nano, Vim or Zed.
- Git if you want to download and update EditorBookmarks with Git.

You can use EditorBookmarks from Bash, Zsh or Fish. The `eb` command itself
uses Bash.

## Installation

### Get the source files

To download with Git, open a terminal and run these commands. They create
`~/src` if needed and clone the repository into `~/src/editorbookmarks`.

```bash
mkdir -p ~/src
git clone https://github.com/TerminallyBlunt/editor-bookmarks.git ~/src/editorbookmarks
```

If you prefer a download, get a release archive and extract it into a folder
you can find again, such as `~/src`. [GitHub Releases](https://github.com/TerminallyBlunt/editor-bookmarks/releases)

Keep the source folder if you want to run the installer again or uninstall
later.

### Run the installer

Run the installer as your regular user. If your source folder is somewhere
else, use that path on the first line.

```bash
cd ~/src/editorbookmarks &&
./install.sh &&
~/.local/bin/eb -h
```

The last command opens the help and confirms that the launcher works. For most
users, the installer puts the program at `~/.local/share/editorbookmarks/eb`.
The launcher is `~/.local/bin/eb`. The installer also puts completion files
in place and prints setup instructions for each shell.

### Make eb available on PATH

If your terminal recognises `eb -h`, you can start using `eb` right away.
You can also use the full launcher path, `~/.local/bin/eb`.

If the terminal says `eb` was not found, add its directory to your PATH, the
list of directories your shell searches for commands. For Bash or Zsh, put
this line in `~/.bashrc` or `~/.zshrc`, then open a new terminal.

```bash
export PATH="$HOME/.local/bin:$PATH"
```

In Fish, run `fish_add_path ~/.local/bin`.

### Alias alternative

If you prefer an alias, add this to `~/.bashrc` for Bash or `~/.zshrc` for Zsh.

```bash
alias eb='~/.local/bin/eb'
```

In Fish, add the following to `~/.config/fish/config.fish`. Use
`alias --save` in place of `alias` if you prefer to save it as a Fish function.

```fish
alias eb (string escape -- "$HOME/.local/bin/eb")
```

See the setup for your shell if you want Tab completion for the alias.
[Shell completion](#shell-completion)

## Usage

### Create your first bookmark

Set your preferred editor once. `eb` remembers your choice for future
sessions. This example uses Micro. Substitute the command for your editor.

```bash
eb --set-editor micro
```

Add your Bash configuration as a bookmark named `bash`. The description
after `-d` is optional.

```bash
eb -a bash ~/.bashrc -d 'Bash settings'
```

Open the bookmark in your preferred editor.

```bash
eb bash
```

If you open a file before choosing a preferred editor, `eb` asks for one.

### Add a file by relative path

If you already have a Kitty config, go to its directory and give `eb` just
the filename. It saves the full path, so you can open the bookmark from
any directory.

```bash
cd ~/.config/kitty
eb -a kitty kitty.conf -d 'Kitty config'
cd ~
eb kitty
```

### Command reference

Use `eb -h` for a short command reference or `eb --help` for more examples.

| Command | What it does |
| --- | --- |
| `eb mango` | Open a bookmark, or a local file if that bookmark does not exist. |
| `eb ./mango` | Open the local file directly. |
| `eb -a` | Prompt for a name, path and optional description. |
| `eb -a mango /path/to/config.conf -d 'Mango settings'` | Add a bookmark. |
| `eb -u mango` | Prompt for a new path and description. Enter keeps each existing value. |
| `eb -u mango ./config.conf` | Replace the path. |
| `eb -u mango -d 'Window manager settings'` | Replace the description. |
| `eb -u mango -d ""` | Clear the description. |
| `eb -n mango mangosettings` | Rename the bookmark. |
| `eb -r mangosettings` | Display the entry and ask for confirmation. The file stays in place. |
| `eb -l` | List all bookmarks alphabetically. |
| `eb -s 'bash settings'` | Search for a phrase across names, paths and descriptions. |
| `eb --set-editor <editor>` | Validate and save a preferred editor. |
| `eb -e nano bash` | Open the bookmark in Nano for this invocation. |
| `eb hosts --sudo` | Run the editor with `sudo` for this invocation. |

Options can go before or after positional arguments. Their values go immediately
after the option, even if the value starts with a hyphen. Use one operation and
each option at most once. Run help and version as stand-alone commands.

### Bookmark names and paths

Use short, memorable names. Start with a lowercase ASCII letter or digit. The
rest may also contain hyphens and underscores. Each name is unique and multiple
names can point at the same file. If uppercase is the only issue and the
lowercase name is free, `eb` asks you to accept that spelling.

If a positional filename starts with a hyphen, write it as `./-filename`.

Quote shell arguments that contain spaces or shell metacharacters. Leave the
tilde outside quotes if you want the shell to expand it.

```bash
eb -a work ~/'Project Notes/README.md'
eb -d 'Main notes' work ~/notes.md -u
```

At an interactive prompt, type the literal path including its spaces, without
surrounding quotes or added backslashes. `eb` expands an initial `~/` and
preserves symlinks and the meaning of components such as `..`. Relative paths
are interpreted from the current working directory and stored as absolute paths.
The path must lead to an existing regular file when added or replaced. Press
Ctrl+C to cancel a prompt. Prompts require a controlling terminal.

A bookmark name takes precedence over a same-named file in the current
directory, even if the bookmark's target has disappeared. Use an explicit
path such as `eb ./mango` to select the local file. You can rename a bookmark
or update its description while its file is unavailable. Use `eb -u` with the
bookmark name and a replacement path to point it elsewhere.

### Search and output

Search looks for a literal substring in the bookmark name, path or description
and ignores case. Spaces in a quoted query are significant, including leading
and trailing spaces.

List and search align paths and descriptions using the longest name in the
results. A description appears on its own line when present. Unavailable
targets are labelled `[NOT FOUND]`, `[NOT A FILE]` or `[CANNOT CHECK]`.

Paths are green when available and red when unavailable in a colour-enabled
terminal. Interactive prompts are bold and successful interactive changes are
shown in green. Use `--no-color` or set `NO_COLOR` to turn off styling. Piped
and redirected output is plain automatically.

## Shell completion

Tab completion helps you enter bookmark names and file paths. The installer
prints the paths for your account. The examples below use the usual paths.

- **Bash.** If you already use bash-completion, open a new terminal and try
  Tab after typing `eb ` with a trailing space. To load the completion
  now, run the following command. For future sessions, add it to
  `~/.bashrc` after any bash-completion setup. This also works on its own
  and with the alias.

  ```bash
  source ~/.local/share/bash-completion/completions/eb
  ```

- **Zsh.** Add the `fpath` line to `~/.zshrc` before `compinit`. Add the
  second line only if your setup does not already run `compinit`. If you
  use the alias, also add `setopt COMPLETE_ALIASES` so completion can use
  the name `eb`.

  ```zsh
  fpath=("$HOME/.local/share/zsh/site-functions" "${fpath[@]}")
  autoload -Uz compinit && compinit
  ```

- **Fish.** Open a new Fish shell. Fish loads the installed completion
  automatically.

Open a new shell after changing startup files. Try Tab after `eb `, `eb -r `,
or `eb -u `. Tab can also complete paths for opening and for the path argument
of add/update. Interactive prompts inside `eb` accept typed input.

## Editors and wrappers

Choose a single executable name on PATH or an executable path. `zed` or
`zeditor` may be the executable on your system. Use the actual program name if
your shell provides an alias or function. `eb` uses its saved preference or
asks for one. It ignores `VISUAL` and `EDITOR`.

Terminal editors keep control of the terminal. Graphical editors follow their
usual launch behaviour, so the terminal prompt returns when the editor command
exits. To pass options or control when the editor returns, create an executable
wrapper. For example, save this as `~/.local/bin/vim-notes` to enable line
numbers in Vim:

```bash
#!/usr/bin/env bash
exec vim '+set number' -- "$@"
```

Run `chmod +x ~/.local/bin/vim-notes` and use
`eb -e ~/.local/bin/vim-notes bash`. To make this your preferred editor, use
`eb --set-editor ~/.local/bin/vim-notes`.

### Edit a protected file with sudo

Use `--sudo` to open an existing file that your account can locate and your sudo
policy allows you to edit. The flag applies only to the current invocation.
It works with a bookmark or a path, and you can combine it with `-e`.

```bash
eb -a hosts /etc/hosts
eb hosts --sudo
eb --sudo /etc/hosts
eb hosts --sudo -e micro
```

`eb` looks up the bookmark and selects the editor using your usual settings.
It then runs the editor through `sudo`, like typing `sudo micro /etc/hosts`
yourself. The editor runs as root and opens the original file directly.
`sudo` handles authorisation and prompts for a password if needed. The editor
receives the same file argument it would receive for a normal open. See the
[sudo(8) manual](https://manpages.debian.org/trixie/sudo/sudo.8.en.html).

## File locations

For most users, these are the locations.

| Location | What it contains |
| --- | --- |
| `~/.local/share/editorbookmarks/eb` | Installed program |
| `~/.local/bin/eb` | Terminal launcher |
| `~/.config/editorbookmarks/bookmarks_db.txt` | Your bookmarks, one per line |
| `~/.config/editorbookmarks/bookmarks_db.txt.bak` | Previous database, created when a save replaces an existing database |
| `~/.config/editorbookmarks/config.conf` | Your editor preference, such as `editor=micro` |
| `~/.config/editorbookmarks/.lock` | Internal file used to coordinate writes |
| `~/.local/share/bash-completion/completions/eb` | Bash completion |
| `~/.local/share/zsh/site-functions/_eb` | Zsh completion |
| `~/.config/fish/completions/eb.fish` | Fish completion |

### XDG directory overrides

If you've set custom XDG directories, substitute these base paths in the
examples above. Use absolute paths for the overrides.

| Setting | Usual base it replaces | What moves |
| --- | --- | --- |
| `XDG_DATA_HOME` | `~/.local/share` | The installed program and Bash and Zsh completions |
| `XDG_CONFIG_HOME` | `~/.config` | The bookmark database, backup, editor preference, lock and Fish completion |

The launcher stays at `~/.local/bin/eb`. Use the same overrides when
installing, running, updating or uninstalling EditorBookmarks.

### Database and recovery

The database is plain text. For manual editing, let any running `eb`
operations finish, make a copy, then keep exactly three fields per line:

```text
bash|/home/peter/.bashrc|
mango|/home/peter/.config/mango/config.conf|Main MangoWM settings
```

Keep the final separator even when the description is empty. Fields cannot
contain a literal pipe or line break, and paths must be absolute. A blank line,
invalid field or duplicate name prevents normal commands from running. The
error gives the line number. A missing target is valid stored data. Help and
version are available while you repair the database.

To recover from the backup, let any `eb` operations finish, then run the
following in Bash. The first line uses the usual bookmark folder. If you use
a custom configuration directory, substitute your bookmark folder. The
commands check for a backup and save a copy of the current database before
restoring it. Keep that copy while checking the result with `eb -l`.

```bash
cd ~/.config/editorbookmarks &&
test -f bookmarks_db.txt.bak &&
recovery_dir=$(mktemp -d ./recovery.XXXXXXXX) &&
cp -- bookmarks_db.txt.bak "$recovery_dir/restored" &&
{ if test -e bookmarks_db.txt; then cp -- bookmarks_db.txt "$recovery_dir/original"; fi; } &&
mv -fT -- "$recovery_dir/restored" bookmarks_db.txt
```

Keep independent copies if you need more than one previous version. The
application maintains a single backup and does not detect or coordinate manual
edits made concurrently with its commands.

## Updating

**If you installed from a Git clone**, open a terminal in the source folder.
Download the latest changes, then rerun the installer if the Git update succeeds.

```bash
git pull --ff-only &&
./install.sh
```

**If you installed from an archive**, download and extract the newer release.
Open a terminal in the newly extracted source folder and run `./install.sh`.

Either way, the installer reports `Updated` when it replaces an existing
installation. Your bookmarks, backup and preferred editor stay in place. Run
`eb -v` to check the installed version.

## Uninstallation

Open a terminal in the source folder and run `./uninstall.sh` as your
regular user. This removes the installed program, launcher and completion files
it owns. You can remove any alias or startup lines you added by hand.

If you also want to delete your bookmarks and editor preference, save anything
you want to keep, then remove `~/.config/editorbookmarks`. See the folder
details if you use a custom configuration directory. [File locations](#file-locations)

## Licence

MIT. See [LICENSE](LICENSE).
