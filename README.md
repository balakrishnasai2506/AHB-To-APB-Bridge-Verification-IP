# AHB-To-APB-Bridge-Verification-IP

This project implements a Verification IP (VIP) for an AHB to APB Bridge, designed using SystemVerilog and verified with UVM (Universal Verification Methodology). The bridge facilitates seamless communication between the high-performance AHB bus and the low-power APB bus.

## Key Features
- Seamless bridging between AHB (master) and APB (slave) interfaces.
- Verification environment developed with SystemVerilog and UVM.
- Two test scenarios implemented:
  - INCR (Incremental burst)
  - WRAP (Wrap-around burst)
- Comprehensive functional coverage using SystemVerilog coverage models.
- Achieved 97.65% functional coverage and 100% coverage with Assertion-Based Verification (SVA).
- Robust error detection and protocol violation checks.
