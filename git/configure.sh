#!/usr/bin/env bash

set -e

# Shared settings go to the XDG path so ~/.gitconfig is left for this
# machine's identity (user.name, user.email, user.signingkey). The Dev
# Containers extension copies the host's ~/.gitconfig into each container,
# which brings the identity along without a bind mount. It copies only that
# one file and ignores [include] directives, so the identity must be inline.
git_xdg_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/git"
mkdir -p "${git_xdg_dir}"
if [ -e "${git_xdg_dir}/config" ] && [ ! -L "${git_xdg_dir}/config" ]; then
    echo "🟡 ${git_xdg_dir}/config exists and is not a symlink; leaving it alone"
else
    ln -sf "${DOTFILES_LOCATION}/git/gitconfig" "${git_xdg_dir}/config"
fi

# Older installs symlinked ~/.gitconfig to the shared config. Remove that link
# so ~/.gitconfig can hold this machine's identity.
if [ -L "${HOME}/.gitconfig" ] &&
    [ "$(readlink -f "${HOME}/.gitconfig")" = "$(readlink -f "${DOTFILES_LOCATION}/git/gitconfig")" ]; then
    rm "${HOME}/.gitconfig"
fi

# A missing identity matters only on Workstations, the only machines that run
# Full mode: Dev containers get the Host's ~/.gitconfig, and nothing is
# committed from Lab servers. So warn only in Full mode.
if [ "${INSTALL_MODE}" = 'full' ] && [ ! -f "${HOME}/.gitconfig" ]; then
    cat <<'EOF'
🟡 ~/.gitconfig is missing. Commits are GPG signed, so create it with this machine's identity:
   [user]
     name = Your Name
     email = you@example.com
     signingkey = <gpg key id>
EOF
fi

ln -sf "${DOTFILES_LOCATION}/git/gitignore_global" "${HOME}/.gitignore_global"

# Keep the shared Git template separate from repos so repo-local hook
# installers cannot rewrite the tracked hooks through a directory symlink.
hooks_dir="${HOME}/.git-template/hooks"
if [ -L "${hooks_dir}" ]; then
    rm "${hooks_dir}"
fi
mkdir -p "${hooks_dir}"
for hook in "${DOTFILES_LOCATION}"/git/git-template/hooks/*; do
    hook_name="${hook##*/}"
    target="${hooks_dir}/${hook_name}"
    if [ -L "${target}" ]; then
        rm "${target}"
    fi
    cp -f "${hook}" "${target}"
done
