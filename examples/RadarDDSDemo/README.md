# RadarDDSDemo

Two-process Cyclone DDS demo that owns its IDL and uses `CycloneDDSLib`
templates with per-topic QoS.

| Binary | Role |
|--------|------|
| `RadarDDSRadar` | Receives commands; publishes tracks, component status, alerts |
| `RadarDDSWorkstation` | Sends commands; receives status/tracks/alerts |

## Build (container)

```bash
cmake --preset debug
cmake --build --preset debug --target RadarDDSRadar RadarDDSWorkstation
```

Binaries: `build/debug/bin/RadarDDSRadar` and `RadarDDSWorkstation`.

## Run locally (same host / domain)

```bash
# terminal 1
./build/debug/bin/RadarDDSRadar 0

# terminal 2
./build/debug/bin/RadarDDSWorkstation 0
```

Optional stress mode on the radar (forces Best-Effort track drops):

```bash
./build/debug/bin/RadarDDSRadar 0 --stress
```

## Run via Compose

From the repo root (after `docker build -t omniscopedds-dev .`):

```bash
docker compose -f deploy/docker-compose.yml up --build
```

That starts Radar, Workstation, and Omniscope on `dds-net` (domain 0).

## Topics / QoS

| Topic | Reliability | Durability | History |
|-------|-------------|------------|---------|
| RadarCommand | Reliable | Volatile | KeepLast(10) |
| RadarCommandStatus | Reliable | Volatile | KeepLast(10) |
| RadarTrack | Best Effort | Volatile | KeepLast(1) |
| RadarComponentStatus | Reliable | TransientLocal | KeepLast(1) |
| RadarAlert | Reliable | TransientLocal | KeepAll (≤50/instance) |
