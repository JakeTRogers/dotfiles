# Ship a patched gitstatusd for relative worktrees

The Shared Git config sets `worktree.useRelativePaths` so that worktrees keep working in a Dev container, where the Checkout is mounted at a different path than on the Host. Git marks every repo that has had a relative worktree with `extensions.relativeWorktrees`. The gitstatusd that powerlevel10k uses for the prompt's Git segment is statically linked against a libgit2 fork from 2020, which rejects that extension, so the prompt shows no branch in those repos, even after the worktrees are gone. Upstream libgit2 fixed this in 1.9.4, but gitstatus is in maintenance mode and its author has said he does not plan to keep developing it. We decided to build gitstatusd ourselves with a one-line libgit2 patch, publish it as a release of this repo, and have the omz Configure step install it.

## Considered Options

- **Drop relative worktrees and mount the Checkout at the Host's path in each Dev container.** Absolute worktree paths then work on both sides, but every project's `devcontainer.json` needs the mount.
- **Disable gitstatus and let powerlevel10k fall back to `vcs_info`.** It runs the real `git`, so it reads the repo, but the prompt blocks on every render in large repos and loses the ahead/behind, stash and change counts.
- **Switch to another prompt, such as Starship.** It means rewriting the prompt, and whether its Git library reads the extension is unverified.

## Consequences

- The binary lives in GitHub releases under `gitstatusd-v*` tags, never in Git history, so cloning the repo costs only the patch and scripts.
- Powerlevel10k starts gitstatusd only when its version matches the gitstatus it bundles. When a powerlevel10k update changes that version, the prompt quietly falls back to powerlevel10k's own gitstatusd, and the Configure step warns until a matching release is pinned.
- Only x86_64 is built. Other architectures keep powerlevel10k's own gitstatusd.
- The binary installs into the home directory, so it survives a Rebuild in a Dev container with a Home volume, as ADR 0001 requires for getRelease Tools.
