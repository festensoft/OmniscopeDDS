# OmniscopeDDS Deployment

Containerized runtime for the RadarDDSDemo pair plus Omniscope.

The deploy image builds from `omniscopedds-dev` and FetchContents CommonUtils
during `cmake --preset release` (needs network to GitHub at build time). The
shared library lands in `build/release/bin/` alongside the executables.

## Prerequisites

```bash
docker build -t omniscopedds-dev .
```

## Run

```bash
docker compose -f deploy/docker-compose.yml up --build
```

| Service | Process |
|---------|---------|
| `radar` | `RadarDDSRadar 0` |
| `workstation` | `RadarDDSWorkstation 0` |
| `omniscope` | `Omniscope 0 8080` → http://localhost:8080 |

Stop with:

```bash
docker compose -f deploy/docker-compose.yml down
```

## DDS discovery

`cyclonedds.xml` lists Compose service names as unicast peers (`radar`,
`workstation`, `omniscope`) for networks where multicast is unavailable.
