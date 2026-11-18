#!/usr/bin/env bash

set -e

# devcontainers will automatically link ~/.gitconfig
if [ "${INSTALL_MODE}" = 'full' ]; then
    test -f "${HOME}/.gitconfig" || ln -sf "${DOTFILES_LOCATION}/git/gitconfig" "${HOME}/.gitconfig"
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
