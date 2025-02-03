
## About 
Implementation of UART ALU on an FPGA using verilog, SystemVerilog, TCL, Python. Implemented at UC Santa Cruz in collaboration with @MochiButter.
Based on [https://github.com/sifferman/verilog_template/](url)
Includes RTL, Design Verification Testbench, Synthesis using open-source toolchain. Uses Third-party IP for UART, SystemVerilog to Verilog, and ALU.
## Languages / Tools used
* SystemVerilog
* Verilog
* TCL
* Python
* Makefile
* Github actions - automated workflow
* Yosys - to run gate-level or post-synthesis simulation
* Verilator - for lint and simulation
Also has 
## Dependencies

* <https://github.com/YosysHQ/oss-cad-suite-build/releases>
* <https://github.com/zachjs/sv2v/releases>
* <https://www.xilinx.com/support/download.html>

## Running

```bash
git submodule update --init --recursive

# simulate with Verilator
make sim

# generic synthesis with Yosys, then simulate with Verilator
make gls

# Icebreaker synthesis with Yosys/Icestorm, then simulate with Verilator
make icestorm_icebreaker_gls
# program Icebreaker volatile memory
make icestorm_icebreaker_program
# program Icebreaker non-volatile memory
make icestorm_icebreaker_flash
```

