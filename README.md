# zephyr-devenv

Reusable Docker build environment for Zephyr-based firmware projects, supporting both Nordic nRF Connect SDK (NCS) and vanilla Zephyr.

Images are published to Docker Hub: [`vinaydivakar/zephyr-devenv`](https://hub.docker.com/r/vinaydivakar/zephyr-devenv)

## What's included

- Ubuntu 24.04 base
- Zephyr SDK toolchain (`arm-zephyr-eabi`)
- Python virtual environment with `west` and all SDK dependencies baked in
- No runtime pip installs needed

## Available tags

| Tag | SDK | Toolchain |
|-----|-----|-----------|
| `ncs-v3.2.0` | nRF Connect SDK v3.2.0 | Zephyr SDK 0.17.4 |
| `zephyr-v4.2.0` | Zephyr v4.2.0 | Zephyr SDK 0.17.4 |

## Usage

Pull whichever image your project needs:

```bash
# Nordic NCS project
docker pull vinaydivakar/zephyr-devenv:ncs-v3.2.0

# Vanilla Zephyr project
docker pull vinaydivakar/zephyr-devenv:zephyr-v4.2.0
```

Use as a base image in your project's Dockerfile:

```dockerfile
FROM vinaydivakar/zephyr-devenv:ncs-v3.2.0

WORKDIR /workdir
CMD ["/bin/bash"]
```

Or run interactively with your workspace mounted:

```bash
docker run --rm -it \
  -v $(pwd):/workdir \
  vinaydivakar/zephyr-devenv:ncs-v3.2.0
```

## Building images

Use the Makefile to build and push both variants:

```bash
# Build and push both images with default versions
make all

# Build or push one variant at a time
make build-ncs
make push-ncs
make build-zephyr
make push-zephyr

# Override versions
make build-ncs NCS_VERSION=v2.9.0
make all ZEPHYR_VERSION=v4.1.0 ZEPHYR_SDK_VERSION=0.16.8

# Show current variable values
make help
```

## Build arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `SDK_VARIANT` | `ncs` | `ncs` or `zephyr` |
| `NCS_VERSION` | `v3.2.0` | nRF Connect SDK tag |
| `ZEPHYR_VERSION` | `v4.2.0` | Zephyr kernel tag |
| `ZEPHYR_SDK_VERSION` | `0.17.4` | Zephyr toolchain SDK version |
| `WEST_VERSION` | `1.5.0` | west pip package version |

## Adding a new SDK version

1. Build and push the new tag:
   ```bash
   make all NCS_VERSION=v3.3.0
   ```
2. Update consuming projects to reference the new tag in their `Dockerfile` or CI pipeline.
