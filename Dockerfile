FROM ubuntu:24.04

# -----------------------------------------------------------------------------
# Build arguments – override with --build-arg at docker build time
#
# SDK_VARIANT       : ncs | zephyr
# NCS_VERSION       : nRF Connect SDK tag  (used when SDK_VARIANT=ncs)
# ZEPHYR_VERSION    : Zephyr kernel tag    (used when SDK_VARIANT=zephyr)
# ZEPHYR_SDK_VERSION: Zephyr toolchain SDK version (shared by both variants)
# WEST_VERSION      : west pip package version
#
# Examples:
#   docker build --build-arg SDK_VARIANT=ncs    --build-arg NCS_VERSION=v3.2.0    -t devenv:ncs .
#   docker build --build-arg SDK_VARIANT=zephyr --build-arg ZEPHYR_VERSION=v4.2.0 -t devenv:zephyr .
# -----------------------------------------------------------------------------
ARG SDK_VARIANT=ncs
ARG NCS_VERSION=v3.2.0
ARG ZEPHYR_VERSION=v4.2.0
ARG ZEPHYR_SDK_VERSION=0.17.4
ARG WEST_VERSION=1.5.0

ENV DEBIAN_FRONTEND=noninteractive

# Expose variant at runtime so tooling inside the container can inspect it
ENV SDK_VARIANT=${SDK_VARIANT}

# Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Zephyr SDK toolchain location (resolved from ZEPHYR_SDK_VERSION ARG at build time)
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/bin:$PATH"

# -----------------------------------------------------------------------------
# Install Ubuntu packages
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    gperf \
    ccache \
    device-tree-compiler \
    wget \
    curl \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    xz-utils \
    file \
    make \
    gcc \
    gcc-multilib \
    g++-multilib \
    ca-certificates \
    ruby \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Install Zephyr SDK toolchain
# -----------------------------------------------------------------------------
RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64_minimal.tar.xz \
    && tar xf zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64_minimal.tar.xz -C /opt \
    && /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}/setup.sh -t arm-zephyr-eabi \
    && rm zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64_minimal.tar.xz

# -----------------------------------------------------------------------------
# Create Python virtual environment and upgrade pip
# -----------------------------------------------------------------------------
RUN python3 -m venv $VIRTUAL_ENV && pip install --no-cache-dir --upgrade pip

# -----------------------------------------------------------------------------
# Install west + SDK-specific Python requirements
#
# NCS    : pins against sdk-nrf and sdk-mcuboot for the given NCS_VERSION
# Zephyr : pins against the upstream Zephyr repo for the given ZEPHYR_VERSION
# -----------------------------------------------------------------------------
RUN pip install --no-cache-dir west==${WEST_VERSION} \
    && if [ "$SDK_VARIANT" = "ncs" ]; then \
        pip install --no-cache-dir \
            -r https://raw.githubusercontent.com/nrfconnect/sdk-nrf/${NCS_VERSION}/scripts/requirements.txt \
            -r https://raw.githubusercontent.com/nrfconnect/sdk-mcuboot/ncs-${NCS_VERSION}/scripts/requirements.txt; \
    else \
        pip install --no-cache-dir \
            -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/${ZEPHYR_VERSION}/scripts/requirements.txt \
            -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/${ZEPHYR_VERSION}/scripts/requirements-build-test.txt; \
    fi

# -----------------------------------------------------------------------------
# Common Python utilities (both variants)
# -----------------------------------------------------------------------------
RUN pip install --no-cache-dir \
    pyelftools \
    intelhex \
    tabulate \
    junitparser \
    psutil \
    pyyaml \
    pytest \
    pyserial \
    anytree \
    ply \
    natsort

# -----------------------------------------------------------------------------
# Workspace
# -----------------------------------------------------------------------------
RUN mkdir -p /workdir
WORKDIR /workdir

CMD ["/bin/bash"]
