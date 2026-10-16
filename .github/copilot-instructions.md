# OmniscopeDDS — contributor notes

## Layout

- `source/DdsCore` — vendor-agnostic interfaces and POD types (header-only)
- `source/CycloneDDS` — Cyclone implementation; public headers in `include/CycloneDDS/`
- `source/Omniscope` — inspector app; public API is `ITransport.h` only
- `examples/RadarDDSDemo` — typed demo with its own IDL
- `deploy/` — Compose runtime for radar + workstation + Omniscope

## Rules

- Do **not** add application IDL to `source/CycloneDDS` — keep that library type-agnostic
- Prefer `LoggerMacros.h` (`GPINFO` / `GPWARN` / `GPERROR`) over ad-hoc logging
- Unit tests: `DDSTopicConfig` and `RawSampleJsonCodec` only; no live DDS in unit tests
- Supported build path: Dev Container / root `Dockerfile` (Cyclone 11.0.1)

## Docs

- [README.md](../README.md) — quick start
- [docs/GUIDE.md](../docs/GUIDE.md) — build and run
- [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) — module boundaries
