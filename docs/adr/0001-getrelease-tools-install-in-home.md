# getRelease Tools install into ~/.local/bin

A Dev container whose home directory is a Home volume runs the Installer only on its first build, so a Rebuild keeps every Configure step result but loses every Install step result outside the home directory. Losing fzf this way broke fzf-tab completion. We decided that getRelease, and every Tool it installs (fzf, bat, fd, ripgrep), installs into `~/.local/bin` without sudo on every machine, so these Tools live in the Home volume and survive a Rebuild.

## Considered Options

- **Re-run the Installer from each project's `postCreateCommand`.** It repairs every Rebuild, but needs a setting in every project and makes each Rebuild as slow as an install.
- **Persist only the home state worth keeping.** Every Rebuild becomes a fresh install, but each kept item needs its own mount.
- **Install the Tools in each project's image.** This duplicates the Installer in every project.
- **Warn at shell start about missing Tools.** It names the problem without fixing it.

## Consequences

- Only new installs move. A machine switches when getRelease has no config file of its own and none of its recorded binaries still exists outside `~/.local/bin`. Workstations and Lab servers with live installs in `/usr/local/bin` keep them, installed with sudo, until getRelease can move recorded installs to a new install directory (JakeTRogers/getRelease#47).
- Tools from the OS package manager, such as tmux and vim, are still lost on a Rebuild. The shell works without them instead of failing: the editor falls back from nvim to vim to vi, and the tmux plugin loads only when tmux is installed.
- Configure step changes still reach a Dev container with a Home volume only when the Installer runs again. A reminder at shell start flags a Checkout that is behind origin, or that has moved since the Installer last ran.
