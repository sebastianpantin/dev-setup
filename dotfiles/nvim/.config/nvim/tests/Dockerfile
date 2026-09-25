# Test environment for this Neovim config. Build context is the config dir:
#   docker build -f tests/Dockerfile -t nvim-config-test .
# Plugins and treesitter parsers are baked into the image, so a test run only
# has to copy in the config and start Neovim. See tests/docker.sh.
FROM ubuntu:24.04

# git + compiler: plugin installs, telescope-fzf-native (make) and treesitter
# parsers. ripgrep: telescope live_grep.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential ca-certificates curl git ripgrep \
	&& rm -rf /var/lib/apt/lists/*

# Pinned to the version used locally; Ubuntu's own package is far too old.
ARG NVIM_VERSION=v0.12.5
RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
		| tar -xz -C /opt \
	&& ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

ENV NVIM_TEST_ENV=/test-env
WORKDIR /config
COPY . /config
RUN tests/run.sh --setup-only

# Mount a working copy over /config to test uncommitted changes.
CMD ["tests/run.sh"]
