# Ice Stick Blinky (Getting Started)

This repository is a minimal getting-started project for the Lattice iCEstick (iCE40HX1K) development board. It builds a simple “blinky” design that drives the on‑board LEDs from the 12 MHz clock.

## What’s in here

- `rtl/blinky.sv` – the top-level SystemVerilog module.
- `constraints/icestick.pcf` – pin constraints for the iCEstick board.
- `apio.ini` – Apio project configuration (board, top module, constraints).
- `Makefile` – convenience targets for build, sim, and upload.

## Prerequisites

- iCEstick board connected over USB
- Apio installed (see OS-specific guides below)

Apio manages the FPGA toolchain and programmer. Follow the official Apio install steps for your operating system.

## Install Apio (by OS)

Choose one of the supported methods for your platform (pip, installer, Debian package, or bundle). The Apio docs list the current downloads and exact steps.

### macOS (Apple Silicon or Intel)

- Installer: download the macOS installer from the latest Apio release and run it; the installer adds Apio to your PATH automatically.
- Pip: ensure Python is installed, then install Apio with pip.
- Bundle: download the macOS bundle, unpack it, and add the `apio` directory to your PATH.

### Linux (x86-64 or ARM64)

- Pip: ensure Python is installed, then install Apio with pip.
- Debian package (x86-64): download the Debian package from the latest release and install it with your system package manager.
- Bundle: download the Linux bundle, unpack it, and add the `apio` directory to your PATH.

### Windows (x86-64)

- Installer: download the Windows installer from the latest Apio release, unblock it, and run the wizard.
- Pip: ensure Python is installed, then install Apio with pip.
- Bundle: download the Windows bundle, unblock it, unpack it, and add the `apio` directory to your PATH.

## Build the bitstream

From the repository root, use the Makefile:

```bash
make synth
```

## Flash (program) the iCEstick

Plug in the board, then use the Makefile:

```bash
make prog
```

If the upload fails, make sure the board is detected and that your USB permissions/drivers are set up correctly for your OS. On Linux and Windows, some boards require FTDI or serial drivers; see the Apio driver guidance for details.

## Troubleshooting

If you run into issues flashing the board, try the following:

- Run `make info` to verify the iCEstick is detected.
- Unplug/replug the board and try a different USB cable or port.
- Ensure your OS has the correct USB permissions/drivers for the iCEstick; on Linux/Windows this may require FTDI or serial drivers.
- Run `make synth` first, then `make prog`, to confirm the bitstream builds cleanly before upload.
- If another programmer tool is open (like a serial terminal), close it and retry.

## Optional: Simulate or lint

```bash
make sim
make test
make lint
```

## Notes

- The top module is `blinky` and expects a 12 MHz clock input on the iCEstick.
- LED outputs are mapped in `constraints/icestick.pcf`.
