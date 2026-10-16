# OmniscopeDDS

Web-based DDS traffic inspector built on Eclipse Cyclone DDS. It discovers
topics at runtime, records opaque CDR samples, and supports playback —
without compiling application IDL into the inspector.

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

## Quick start (Dev Container)

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
./build/debug/bin/Omniscope
# optional demo:
./build/debug/bin/RadarDDSRadar 0
./build/debug/bin/RadarDDSWorkstation 0
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

This project is licensed under the [MIT License](LICENSE).
