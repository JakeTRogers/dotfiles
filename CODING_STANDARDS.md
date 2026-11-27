# Coding standards

House conventions that need judgement to apply. Mechanical rules belong in pre-commit, not here.

## Status markers in Installer output

Each status line the Installer prints starts with one status marker. Continuation lines of a multi-line message, such as the config snippet in a warning, carry none.

| Marker | Meaning                                                 |
| ------ | ------------------------------------------------------- |
| 🟢     | Success, or the work was already done                   |
| 🔴     | Failure                                                 |
| ⚠️     | Warning: something is wrong, but the Installer continues |
| 🔵     | Configuring a Tool (its Configure step)                 |
| ⚪     | Installing a Tool (its Install step)                    |

⚠️ is the only warning marker. Don't use 🟡 or other markers for warnings.

These rules cover Installer output only: the `echo` lines in each Tool's `install.sh` and `configure.sh`, and the lines the `bin/dotfiles` runner prints. The omz functions follow their own `pprint` conventions, where 🔵 means general information, so don't flag those against this table.

## Glossary terms

The terms in `GLOSSARY.md` apply everywhere, not only in docs: code comments, user-facing messages and commit bodies use them too. Words in a term's _Avoid_ list stay out of all of these, so write "Configure step" in a comment, not "setup", and "Tool" in a message, not "package".
