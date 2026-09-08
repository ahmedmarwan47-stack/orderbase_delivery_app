# orderbase_delivery_app

Flutter port of the Orderbase courier app — Arabic-first (RTL), built from the `.dc.html`
mockups in the Claude Design project. Architecture, design tokens, and screen inventory are
documented in [`CLAUDE.md`](CLAUDE.md).

## Getting started

New machine? Follow **[`docs/LOCAL_SETUP.md`](docs/LOCAL_SETUP.md)** — it lists everything to
install (Flutter SDK, Xcode housekeeping, SSH access, editor) and the optional extras.

Already set up:

```bash
flutter pub get
open -a Simulator
flutter run
```

Verify the toolchain at any time with `./scripts/doctor.sh`.
