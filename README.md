Everything related to dev setup will be in this repo, such as dotfiles and install scripts

## New machine

On a fresh Omarchy install:

```sh
git clone https://github.com/sebastianpantin/dev-setup.git ~/programming/dev-setup
~/programming/dev-setup/install-scripts/install-all.sh
```

It asks for the sudo password once. Log out and back in afterwards, so zsh becomes the shell and the docker and kvm groups apply.

Each `install-*.sh` script can also be run on its own.

Machine-specific shell settings go in `~/.zshrc.local`, which `.zshrc` sources and the repo does not track.

## Testing

`install-scripts/tests/docker.sh` runs the shell part of the install (CLI tools, stow, zsh, dotfiles, oh-my-zsh, login shell) in a fresh Arch container and checks the result. Work tools, Android and Hyprland overrides need the AUR, large downloads or a real Omarchy session, so they are left out.
