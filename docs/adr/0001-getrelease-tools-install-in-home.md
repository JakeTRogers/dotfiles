# getRelease Tools install into ~/.local/bin

A Dev container whose home directory is a Home volume runs the Installer only on its first build, so a Rebuild keeps every Configure step result but loses every Install step result outside the home directory. Losing fzf this way broke fzf-tab completion. We decided that getRelease, and every Tool it installs (fzf, bat, fd, ripgrep), installs into `~/.local/bin` without sudo on every machine, so these Tools live in the Home volume and survive a Rebuild.

## Considered Options

- **Re-run the Installer from each project's `postCreateCommand`.** It repairs every Rebuild, but needs a setting in every project and makes each Rebuild as slow as an install.
- **Persist only the home state worth keeping.** Every Rebuild becomes a fresh install, but each kept item needs its own mount.
- **Install the Tools in each project's image.** This duplicates the Installer in every project.
- **Warn at shell start about missing Tools.** It names the problem without fixing it.

## Consequences

- Existing machines move too. Each Installer run moves every binary that getRelease recorded elsewhere, such as in `/usr/local/bin`, into `~/.local/bin` with `getRelease relocate` (getRelease 1.7.0 and later), removes the old copies with sudo, and then sets getRelease's `installDir` and `installCommand` to `~/.local/bin` without sudo. When relocate blocks a move, because a different file is already in `~/.local/bin` or a binary cannot be installed there, the Installer fails and both settings stay as they were, so the machine can still upgrade with sudo until a later run finishes the move.
- Moved binaries are no longer on root's `PATH` or on other accounts' `PATH`, so `sudo <tool>` stops finding them.
- Tools from the OS package manager, such as tmux and vim, are still lost on a Rebuild. The shell works without them instead of failing: the editor falls back from nvim to vim to vi, and the tmux plugin loads only when tmux is installed.
- Configure step changes still reach a Dev container with a Home volume only when the Installer runs again. A reminder at shell start flags a Checkout that is behind origin, or that has moved since the Installer last ran.
