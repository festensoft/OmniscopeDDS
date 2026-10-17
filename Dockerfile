# =============================================================================
# OmniscopeDDS Development Container
#
# Dependencies are built from source. The container is the dependency manager.
# CMake FetchContent pulls CommonUtils (v1.0.0) at configure time.
#
# Build:
#   docker build -t omniscopedds-dev .
#
# Run (mount source as volume):
#   docker run -v $(pwd):/workspace -w /workspace -it omniscopedds-dev
#
# Build inside container:
#   cmake --preset debug
#   cmake --build --preset debug
# =============================================================================

FROM ubuntu:24.04

# ---- Dependency versions (override with --build-arg) -----------------------
ARG CMAKE_VERSION=4.1.2
ARG SPDLOG_VERSION=v1.15.0
ARG CYCLONEDDS_VERSION=11.0.1
ARG CYCLONEDDS_CXX_VERSION=11.0.1
ARG CROW_VERSION=v1.2.0
ARG GTEST_VERSION=v1.14.0

# ---- Prevent interactive prompts -------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive

# ---- Build tools and system libraries ---------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      g++ \
      clang \
      clang-format \
      clangd \
      ninja-build \
      python3 \
      git \
      curl \
      ca-certificates \
      pkg-config \
      libasio-dev \
      libssl-dev \
      zlib1g-dev \
      lcov \
      gcovr \
      clang-tidy \
    && rm -rf /var/lib/apt/lists/*

# ---- CMake >= 4.1 (required by CommonUtils; Ubuntu 24.04 ships 3.28) --------
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
      amd64) CMAKE_ARCH="x86_64" ;; \
      arm64) CMAKE_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.tar.gz" \
      -o /tmp/cmake.tar.gz && \
    tar -xzf /tmp/cmake.tar.gz -C /usr/local --strip-components=1 && \
    rm /tmp/cmake.tar.gz && \
    cmake --version

# Belt-and-suspenders: rewrite git@ → HTTPS so any FetchContent / clone that
# still uses SSH URLs works without an SSH agent inside the container.
RUN git config --system url."https://github.com/".insteadOf "git@github.com:"

# ---- spdlog (also discoverable by CommonUtils via find_package) ------------
RUN git clone --depth 1 --branch ${SPDLOG_VERSION} \
      https://github.com/gabime/spdlog.git /tmp/spdlog \
    && cmake -S /tmp/spdlog -B /tmp/spdlog/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_CXX_STANDARD=20 \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
       -DSPDLOG_USE_STD_FORMAT=ON \
       -DSPDLOG_BUILD_EXAMPLE=OFF \
       -DSPDLOG_BUILD_TESTS=OFF \
    && cmake --build /tmp/spdlog/build \
    && cmake --install /tmp/spdlog/build \
    && rm -rf /tmp/spdlog

# ---- Eclipse Cyclone DDS (C binding + IDL compiler) ------------------------
RUN git clone --depth 1 --branch ${CYCLONEDDS_VERSION} \
      https://github.com/eclipse-cyclonedds/cyclonedds.git /tmp/cyclonedds \
    && cmake -S /tmp/cyclonedds -B /tmp/cyclonedds/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
       -DBUILD_TESTING=OFF \
       -DBUILD_EXAMPLES=OFF \
       -DBUILD_IDLC=ON \
       -DENABLE_ICEORYX=OFF \
    && cmake --build /tmp/cyclonedds/build \
    && cmake --install /tmp/cyclonedds/build \
    && ldconfig \
    && rm -rf /tmp/cyclonedds

# ---- Eclipse Cyclone DDS C++ -----------------------------------------------
RUN git clone --depth 1 --branch ${CYCLONEDDS_CXX_VERSION} \
      https://github.com/eclipse-cyclonedds/cyclonedds-cxx.git /tmp/cyclonedds-cxx \
    && cmake -S /tmp/cyclonedds-cxx -B /tmp/cyclonedds-cxx/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
       -DBUILD_TESTING=OFF \
       -DBUILD_EXAMPLES=OFF \
    && cmake --build /tmp/cyclonedds-cxx/build \
    && cmake --install /tmp/cyclonedds-cxx/build \
    && ldconfig \
    && rm -rf /tmp/cyclonedds-cxx

# ---- Crow (C++ HTTP/WebSocket framework) ------------------------------------
RUN git clone --depth 1 --branch ${CROW_VERSION} \
      https://github.com/CrowCpp/Crow.git /tmp/crow \
    && cmake -S /tmp/crow -B /tmp/crow/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DCROW_BUILD_EXAMPLES=OFF \
       -DCROW_BUILD_TESTS=OFF \
    && cmake --build /tmp/crow/build \
    && cmake --install /tmp/crow/build \
    && rm -rf /tmp/crow

# ---- Google Test -----------------------------------------------------------
RUN git clone --depth 1 --branch ${GTEST_VERSION} \
      https://github.com/google/googletest.git /tmp/gtest \
    && cmake -S /tmp/gtest -B /tmp/gtest/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
       -DBUILD_GMOCK=ON \
    && cmake --build /tmp/gtest/build \
    && cmake --install /tmp/gtest/build \
    && rm -rf /tmp/gtest

RUN ldconfig

WORKDIR /workspace
