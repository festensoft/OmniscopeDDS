# OmniscopeDDS

Web-based DDS traffic inspector built on Eclipse Cyclone DDS. It discovers
topics at runtime, records opaque CDR samples, and supports playback —
without compiling application IDL into the inspector.  

Admittedly, this is mostly a vibe-coded project!  Expect instability.  My
intention is to find a need for this tool then rapidly iterate on improving
it once I find an audience.

**Supported workflow:** Dev Container or the root `Dockerfile`. Host-native
toolchains may work but are not maintained.

## Modules

| Module | Role |
|--------|------|
| **source/DdsCore** | Vendor-agnostic discovery / raw-bytes interfaces |
| **source/CycloneDDS** | Cyclone implementation + typed `DDSPublisher`/`DDSSubscriber` |
| **source/Omniscope** | Crow HTTP/WebSocket inspector |
| **examples/RadarDDSDemo** | Radar + Workstation demo (own IDL) |
| **CommonUtils** | FetchContent [festensoft/CommonUtils](https://github.com/festensoft/CommonUtils) `v1.0.0` |

## Quick start (Dev Container, might get lucky building locally)

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
./build/debug/bin/Omniscope <domain>
# optional demo:
./build/debug/bin/RadarDDSRadar <domain>
./build/debug/bin/RadarDDSWorkstation <domain>
```

Open http://localhost:8080

More detail: [docs/GUIDE.md](docs/GUIDE.md) · [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Deploy

```bash
docker build -t omniscopedds-dev .
docker compose -f deploy/docker-compose.yml up --build
```

See [deploy/README.md](deploy/README.md) and
[examples/RadarDDSDemo/README.md](examples/RadarDDSDemo/README.md).

## License

This project is licensed under the [Boost Software License](LICENSE).
