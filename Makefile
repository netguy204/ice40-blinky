# Makefile for Lattice iCEstick (iCE40HX1K)
# Uses apio toolchain

# Project configuration
TOP_MODULE := blinky

# Directories
RTL_DIR := rtl
TB_DIR := tb
CONSTRAINTS_DIR := constraints
BUILD_DIR := build

# Source files
RTL_SOURCES := $(wildcard $(RTL_DIR)/*.sv)
TB_SOURCES := $(wildcard $(TB_DIR)/*.sv)
PCF_FILE := $(CONSTRAINTS_DIR)/icestick.pcf

# Default target
.PHONY: all
all: synth

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build bitstream with apio
.PHONY: synth
synth: | $(BUILD_DIR)
	apio build

# Simulation with apio
.PHONY: sim
sim: | $(BUILD_DIR)
	apio sim

# Run simulation without GTKWave (for CI/testing)
.PHONY: test
test: | $(BUILD_DIR)
	apio sim --no-gtkwave

# Program the FPGA
.PHONY: prog
prog: synth
	apio upload

# Timing analysis
.PHONY: timing
timing: synth
	apio time

# Lint the design
.PHONY: lint
lint:
	apio lint

# Clean build artifacts
.PHONY: clean
clean:
	apio clean
	rm -rf $(BUILD_DIR)/*

# Show board info
.PHONY: info
info:
	apio boards --list

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all      - Build bitstream (default)"
	@echo "  synth    - Synthesize and generate bitstream"
	@echo "  sim      - Run simulation with GTKWave"
	@echo "  test     - Run simulation without GTKWave"
	@echo "  prog     - Program FPGA (upload)"
	@echo "  timing   - Run timing analysis"
	@echo "  lint     - Lint the design"
	@echo "  clean    - Remove build artifacts"
	@echo "  info     - Show supported boards"
	@echo "  help     - Show this message"
