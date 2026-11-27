# Patched gitstatusd

Powerlevel10k reads Git status through gitstatusd, which is statically linked against a 2020 fork of libgit2 (1.1.0). That libgit2 refuses any repo whose config sets an extension it does not know, so gitstatusd treats the repo as not a repo and the prompt loses its branch. The [Shared Git config](../../git/gitconfig) sets `worktree.useRelativePaths`, so the first `git worktree add` in a repo sets `extensions.relativeWorktrees`, and git never removes it.

This directory builds gitstatusd with a one-line patch that accepts `extensions.relativeWorktrees`, the same change upstream libgit2 made in 1.9.4 ([libgit2#7254](https://github.com/libgit2/libgit2/pull/7254)). Why we patch instead of dropping relative worktrees is in [ADR 0002](../../docs/adr/0002-patched-gitstatusd-for-relative-worktrees.md).

## Files

| File                      | Purpose                                                                          |
| ------------------------- | -------------------------------------------------------------------------------- |
| `gitstatusd.env`          | Pins: the gitstatus commit to build, and the release the Configure step installs |
| `relativeworktrees.patch` | The libgit2 change                                                               |
| `build.sh`                | Builds `gitstatusd-linux-x86_64` in podman or docker                             |
| `test.sh`                 | Checks that a binary reads a repo and a worktree that use relative paths         |

The binary is never committed. The [gitstatusd workflow](../../.github/workflows/gitstatusd.yml) builds it and attaches it to a GitHub release, and the omz Configure step downloads it to `~/.local/share/gitstatusd/<version>/gitstatusd` after checking it against `release_sha256`. `zshrc` sets `GITSTATUS_DAEMON` to that file only when `<version>` matches the gitstatus that powerlevel10k bundles, because powerlevel10k refuses a gitstatusd of any other version. Otherwise the prompt uses powerlevel10k's own gitstatusd.

## Build and test locally

```sh
omz/gitstatusd/build.sh out
omz/gitstatusd/test.sh out/gitstatusd-linux-x86_64
```

The build is reproducible: the same pins give a byte-identical binary, locally or in CI. `build.sh` sorts the gitstatus Makefile's source list for this, because upstream links objects in filesystem directory order. `gitstatusd-v1.5.5-1` was built before that fix, so a local build does not reproduce it, but the binaries differ only in link order.

## Release

1. Tag the commit and push the tag. The tag is `gitstatusd-<version>-<n>`, where `<version>` is what the binary reports with `--version` (the `gitstatus_version` of the pinned commit) and `<n>` counts our builds of that version. These tags are separate from the `v*` tags that `cz bump` writes.

   ```sh
   git tag -s gitstatusd-v1.5.5-1 -m 'gitstatusd v1.5.5, build 1'
   git push origin gitstatusd-v1.5.5-1
   ```

2. The workflow builds, tests and publishes the release, without marking it as the latest release. It fails if the tag's version does not match the binary's.
3. Set `release_tag` and `release_sha256` in `gitstatusd.env` from the release notes, and commit that.

## When powerlevel10k updates gitstatus

The omz Configure step prints a ⚠️ warning when the pinned release no longer matches powerlevel10k's gitstatus version, and the prompt falls back to powerlevel10k's own gitstatusd until a new release is pinned. To follow powerlevel10k:

1. Find the gitstatus commit that powerlevel10k bundles: its `gitstatus/` directory is a subtree of [romkatv/gitstatus](https://github.com/romkatv/gitstatus). Set `gitstatus_commit` to it.
2. Run `build.sh`. It fails if the libgit2 fork commit that gitstatus pins has moved and the patch no longer applies; rework the patch against the new commit.
3. Release as above.
