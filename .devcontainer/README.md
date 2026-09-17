# libwallaby devcontainer

A container with everything needed to cross-compile libwallaby for the KIPR Wombat (aarch64), plus Claude Code and Codex.

## What's in the image

The image is the `dev` stage of the repo's root [`Dockerfile`](../Dockerfile). It builds on the same `toolchain` stage as the default `builder` image, so both always use the same compiler and libraries.

- **toolchain stage:** Debian 13, the `aarch64-linux-gnu` GCC cross-compiler, CMake, SWIG, Doxygen, and the arm64 `libx11-dev` and `python3.13-dev` packages that the graphics module and Python bindings link against.
- **dev stage adds:**
  - shell and search tools: fish, git, ripgrep, fd, fzf, jq, curl, ssh
  - `file`, to check the architecture of built binaries
  - `gnupg`, for signed commits through VS Code's GPG forwarding
  - `bubblewrap` and `socat`, for the agent sandboxes
  - the Claude Code and Codex CLIs
- **User:** `code` (UID 1000, home `/home/code`, shell fish).

## Opening it

- **VS Code:** run "Dev Containers: Reopen in Container".
- **CLI:** run `devcontainer up --workspace-folder .`, then `devcontainer exec --workspace-folder . fish`.

## Building libwallaby

Inside the container, from the repo root:

```sh
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=toolchain/aarch64-linux-gnu.cmake .
cmake --build build -j "$(nproc)"
```

This produces `build/libkipr.so` (aarch64) and a Debian package, `build/kipr-*.deb`. To check the architecture, run `file build/libkipr.so`.

The tests build as aarch64 executables for the Wombat. They don't run in this container.

## Building the image without VS Code

```sh
docker build --target dev .    # this devcontainer's image
docker build .                 # the default builder image (unchanged)
```

Rebuild the container whenever the `Dockerfile` or `devcontainer.json` changes. A rebuild also picks up new versions of Claude Code and Codex.

## Agent CLIs

Agent logins and settings are stored in two Docker named volumes, `claude-config` and `codex-config`. Every devcontainer that uses these names shares them, so you log in once per machine and the login survives rebuilds. Nothing from your host's `~/.claude` or `~/.codex` is used.

First-time login and a smoke test:

```sh
claude          # follow the login prompt, then /exit
claude --version
codex           # choose "Sign in with ChatGPT"
codex --version
```

The volumes are shared live. Sessions running in two containers at the same time read and write the same files.

### Sandbox

Both CLIs run commands inside a bubblewrap sandbox. Under Docker's defaults, bubblewrap fails (`Can't mount proc on /proc: Operation not permitted`). So `devcontainer.json` runs the container with:

- `--security-opt=seccomp=unconfined`, which disables Docker's syscall filter for this container
- `--security-opt=systempaths=unconfined`, which unmasks `/proc` and `/sys` paths so bubblewrap can mount a fresh `/proc`

The agent sandboxes become the isolation layer for agent commands. The container itself is less locked down than a default Docker container.

To check the sandboxes:

```sh
codex sandbox -- true                                                     # exit 0
codex sandbox -c sandbox_mode='"workspace-write"' -- touch /home/code/x   # Read-only file system
```

In Claude Code, run `/sandbox`. It shows a Dependencies tab only if something is missing.

## Caveats

- Docker on an SELinux host (such as Fedora) normally mounts the workspace without problems. If VS Code is set to use Podman and the workspace shows as permission denied, add `"--security-opt=label=disable"` to `runArgs`.
- The WASM/emscripten build described in the root `README.md` is not covered by this image.
