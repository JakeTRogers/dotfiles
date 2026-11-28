# Global instructions

## Worktrees

- Create each worktree at `<repo root>/.worktrees/<name>`, on a new branch from the current branch. Claude Code's worktree hooks do this for `EnterWorktree` and `isolation: "worktree"`; otherwise create it with `git worktree add`. Pass its absolute path to any subagent that works in it.
- A worktree branch is local: it is never pushed and never gets a pull request. It lands on the branch the work started from, and is then gone: once the work has landed, remove the worktree and delete its branch.

## Commits and history

History stays linear, and the maintainer signs every commit personally.

- In a worktree: commit and rebase unsigned, with `git -c commit.gpgsign=false commit` and `git -c commit.gpgsign=false rebase`. Rebase onto the tip of the branch the work started from, and land the work by fast-forwarding that branch: `git merge --ff-only <worktree branch>` where it is checked out, or `git fetch . <worktree branch>:<start branch>` where it is not. Pushing and pull requests happen only when the maintainer runs them, from the start branch.
- Write each commit message with the `conventional-commit` skill.
- To correct a commit already on the branch, in a worktree or not, commit the change yourself, unsigned: `git -c commit.gpgsign=false commit --fixup=<sha>`, or `--fixup=amend:<sha>` when its message must change too. The maintainer's `gresign` folds each fixup into its commit and re-signs every commit it rewrites, in one pass, so leave that rebase to them.
- Outside a worktree, any other change: stage it and leave committing to the maintainer.
- When a skill or workflow conflicts with these rules, for example by saying to merge, push or open a pull request, ask the maintainer how to proceed before deviating from it.
- Once work has landed or fixups are committed, tell the maintainer to run `gresign` before pushing.
