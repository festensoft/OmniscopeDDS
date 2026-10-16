# =============================================================================
# OmniscopeDDS Deployment Image (multi-stage)
#
# Prerequisite — build the dev image once (cached, rarely changes):
#   docker build -t omniscopedds-dev .
#
# Then build and run via Compose:
#   docker compose -f deploy/docker-compose.yml up --build
# =============================================================================

# ---- Stage 1: Build the project using the dev image ------------------------
FROM omniscopedds-dev AS builder

COPY . /workspace
WORKDIR /workspace

RUN cmake --preset release \
    && cmake --build --preset release \
       --target Omniscope RadarDDSRadar RadarDDSWorkstation

# ---- Stage 2: Slim runtime image -------------------------------------------
FROM ubuntu:24.04 AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Third-party shared libraries installed into the dev image
COPY --from=builder /usr/local/lib/libddsc.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/libddscxx.so* /usr/local/lib/

# CommonUtils (FetchContent) sets LIBRARY_OUTPUT to ${CMAKE_BINARY_DIR}/bin,
# which is the parent build tree when used as a subdirectory — same bin/ as
# the executables, not _deps/commonutils-build/.
COPY --from=builder /workspace/build/release/bin/libCommonUtils.so* /usr/local/lib/

COPY --from=builder /workspace/build/release/bin/Omniscope /usr/local/bin/
COPY --from=builder /workspace/build/release/bin/RadarDDSRadar /usr/local/bin/
COPY --from=builder /workspace/build/release/bin/RadarDDSWorkstation /usr/local/bin/

RUN ldconfig

EXPOSE 8080
CMD ["bash", "-c", "echo 'Available: Omniscope, RadarDDSRadar, RadarDDSWorkstation'; exec bash"]
