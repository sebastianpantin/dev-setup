# Test environment for this Neovim config. Build context is the config dir:
#   docker build -f tests/Dockerfile -t nvim-config-test .
# Plugins, treesitter parsers and the Mason tools the tests use are baked into
# the image, so a test run only has to copy in the config and start Neovim.
# See tests/docker.sh.
FROM ubuntu:24.04

# git + compiler: plugin installs, telescope-fzf-native (make) and treesitter
# parsers. ripgrep: telescope. unzip: Mason packages (stylua).
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential ca-certificates curl git ripgrep unzip \
	&& rm -rf /var/lib/apt/lists/*

# Pinned to the version used locally; Ubuntu's own package is far too old.
ARG NVIM_VERSION=v0.12.5
RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
		| tar -xz -C /opt \
	&& ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# nvim-treesitter (main branch) builds parsers with the tree-sitter CLI
ARG TREE_SITTER_VERSION=v0.26.9
RUN curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/tree-sitter-linux-x64.gz" \
		| gunzip > /usr/local/bin/tree-sitter \
	&& chmod +x /usr/local/bin/tree-sitter

# Rust toolchain for the rust-analyzer tests: cargo loads the fixture crate,
# rust-src provides the standard library sources, and clippy is the check
# command set in lsp/rust_analyzer.lua. Ubuntu's packages lag far behind the
# releases rust-analyzer supports, so install a pinned one with rustup.
# rust-analyzer itself comes from Mason unpinned (see MASON_TOOLS in
# tests/run.sh), so this may need bumping when a new one drops old toolchains.
ARG RUSTUP_VERSION=1.29.1
ARG RUST_VERSION=1.98.0
ENV RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo PATH=/opt/cargo/bin:$PATH
RUN curl -fsSL -o /tmp/rustup-init \
		"https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-gnu/rustup-init" \
	&& chmod +x /tmp/rustup-init \
	&& /tmp/rustup-init -y --no-modify-path --profile minimal \
		--default-toolchain "${RUST_VERSION}" --component clippy,rust-src \
	&& rm /tmp/rustup-init

ENV NVIM_TEST_ENV=/test-env
WORKDIR /config
COPY . /config
RUN tests/run.sh --setup-only

# Mount a working copy over /config to test uncommitted changes.
CMD ["tests/run.sh", "--all"]
