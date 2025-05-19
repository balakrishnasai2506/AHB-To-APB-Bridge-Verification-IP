# AHB to APB Bridge Verification IP

## Overview
This project implements a Verification IP (VIP) for verifying an AHB to APB Bridge using SystemVerilog and UVM (Universal Verification Methodology). It provides a comprehensive testbench environment to ensure protocol compliance and functional correctness of the bridge design.

## Key Features
- Verification environment developed entirely in SystemVerilog with UVM.
- Supports two primary test scenarios:
  - INCR (Incremental burst)
  - WRAP (Wrap-around burst)
- Functional coverage models for protocol and feature coverage.
- Assertion-Based Verification (SVA) with 100% coverage on key protocol properties.
- Robust error detection and protocol violation reporting.

## Verification Environment Components
- **Sequences:** Implements test scenarios for INCR and WRAP burst types.
- **Drivers:** Drive AHB and APB interface transactions based on sequences.
- **Monitors:** Observe and check protocol compliance on AHB and APB buses.
- **Scoreboards:** Compare expected vs actual responses.
- **Coverage:** Functional coverage models and assertions integrated to monitor verification completeness.
