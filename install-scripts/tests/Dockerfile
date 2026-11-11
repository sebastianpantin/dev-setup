# Fresh Arch box for testing the install scripts. Build context is the repo root:
#   docker build -f install-scripts/tests/Dockerfile -t dev-setup-test .
# Omarchy itself can't run in a container, so this covers the shell setup only.
# See install-scripts/tests/docker.sh.
FROM archlinux:latest

# A sudo user like on a real install. No yay, so install_package uses pacman.
RUN pacman -Syu --noconfirm --needed sudo git curl which \
	&& useradd -m tester \
	&& echo 'tester ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/tester

USER tester
# Login sessions set this; docker does not.
ENV USER=tester
WORKDIR /home/tester
COPY --chown=tester:tester install-scripts /home/tester/programming/dev-setup/install-scripts
COPY --chown=tester:tester dotfiles /home/tester/programming/dev-setup/dotfiles

CMD ["/home/tester/programming/dev-setup/install-scripts/tests/run.sh"]
