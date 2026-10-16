# Guide — build, run, and contribute

Companion to [ARCHITECTURE.md](ARCHITECTURE.md). The root
[README](../README.md) is the front door; this page is the day-to-day
workflow. Runtime packaging lives under [`deploy/`](../deploy/README.md).

## Supported environment

**Containerized development is the supported path.** Open the repo in a Dev
Container, or build from the root `Dockerfile`. The image installs CMake
4.1+, Cyclone DDS 11.0.1, Crow, spdlog, and GTest from source so versions
stay pinned.

```text
Dev Containers: Rebuild and Reopen in Container
```

## Build

Presets live in `CMakePresets.json`. Day-to-day:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

| Option | Default | Meaning |
|--------|---------|---------|
| `BUILD_EXAMPLES` | ON | RadarDDSDemo binaries |
| `BUILD_TESTS` | OFF | Unit tests (`CycloneDDSTests`, `OmniscopeTests`). On for `debug` / `debug-clang` |

Binaries land under `build/<preset>/bin/`:

- `Omniscope`
- `RadarDDSRadar` / `RadarDDSWorkstation` (when examples are on)
- `CycloneDDSTests` / `OmniscopeTests` (when `BUILD_TESTS` is on)

Release:

```bash
cmake --preset release
cmake --build --preset release
```

Clang, sanitizer, and clang-tidy presets are listed in `CMakePresets.json`.

## Run Omniscope

```bash
./build/debug/bin/Omniscope [domain_id] [http_port]
# defaults: domain 0, port 8080
```

Open http://localhost:8080

Omniscope joins the domain, discovers topics as publishers appear, and
supports subscribe / record / playback in the browser. Payloads stay opaque
CDR (hex in the UI); the inspector does not decode application types.

Start a publisher (for example the radar demo below) before expecting a
non-empty topic list.

## Run the RadarDDSDemo

```bash
./build/debug/bin/RadarDDSRadar 0
./build/debug/bin/RadarDDSWorkstation 0
```

Stress mode (Best Effort track spam to observe drops):

```bash
./build/debug/bin/RadarDDSRadar 0 --stress
```

QoS details: [examples/RadarDDSDemo/README.md](../examples/RadarDDSDemo/README.md).

## Layout

```text
source/DdsCore/include/DdsCore/          vendor-agnostic interfaces
source/CycloneDDS/include/CycloneDDS/    public Cyclone API
source/CycloneDDS/src/                   private implementation (BlobSertype, …)
source/Omniscope/include/Omniscope/      ITransport only
source/Omniscope/src/                    application code
source/Omniscope/web/                    HTML/CSS/JS (embedded at build)
examples/RadarDDSDemo/                   IDL + demo apps
```

If a header is not under `include/<Module>/`, it is not part of the public API.

## Logging

```cpp
#include "LoggerMacros.h"

GPINFO("hello {}", name);
GPWARN("suspicious: {}", thing);
GPERROR("nope: {}", why);
```

CommonUtils is FetchContent’d at configure time
(`https://github.com/festensoft/CommonUtils.git` tag `v1.0.0`). The container
rewrites `git@github.com:` to HTTPS so configure works without an SSH agent.

## Adding another typed DDS app

Follow RadarDDSDemo, not the Omniscope raw path:

1. Put IDL in your app/example folder.
2. `idlcxx_generate(...)` in that target’s CMakeLists.
3. Build a `DDSTopicConfig` with matching writer/reader QoS.
4. Use `DDSPublisher<T>` / `DDSSubscriber<T>` with those entries.

Do **not** add IDL to `source/CycloneDDS` — that library stays type-agnostic.

## Troubleshooting

| Symptom | Likely fix |
|---------|------------|
| CMake version &lt; 4.1 | Rebuild the Dev Container image |
| FetchContent cannot clone CommonUtils | Network / GitHub access from the container |
| Empty Omniscope topic list | Nothing is publishing on that domain yet |
| Missing Iceoryx / PSMX symbols in custom sertypes | Expected — Iceoryx is off (`ENABLE_ICEORYX=OFF`) |

## Out of scope here

- Live DDS / Crow integration tests (unit suite covers `DDSTopicConfig` and
  `RawSampleJsonCodec`; compose covers the demo by hand)
- Coverage HTML reports and sanitizer matrices in CI
