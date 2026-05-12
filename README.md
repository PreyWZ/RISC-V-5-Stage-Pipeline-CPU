# RISC-V 5-Stage Pipeline CPU

A 5-stage pipelined processor implementing a subset of the RV32I instruction set, written in SystemVerilog.
Designed for simulation with Verilator and synthesis on Xilinx FPGAs (Nexys A7 / Basys 3).

## Architecture

```
IF → ID → EX → MEM → WB
```

- **IF**: Instruction fetch from IMem, PC update
- **ID**: Instruction decode, register file read, hazard detection
- **EX**: ALU execution, branch resolution, data forwarding
- **MEM**: Data memory read/write via DMem, IO access via IOCtrl
- **WB**: Write-back to register file

### Hazard Handling

| Hazard | Solution |
|--------|----------|
| Data hazard (RAW, 1–2 cycle) | EX/MEM → EX and MEM/WB → EX forwarding |
| Data hazard (WB→ID same-cycle) | Register file read bypass |
| Load-use hazard | 1-cycle pipeline stall |
| Control hazard (branch/jump) | Flush IF/ID and ID/EX stages |

### Supported Instructions

| Type | Instructions |
|------|-------------|
| R-type | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT` |
| I-type | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI` |
| Load/Store | `LW`, `SW` |
| Branch | `BEQ`, `BNE`, `BLT`, `BGE` |
| Jump | `JAL`, `JALR` |
| Upper Imm | `LUI` |

## Project Structure

```
├── BasicTypes.sv          # Base type definitions, address maps, IO constants
├── Types.sv               # ISA-specific types (opcodes, ALU control, func3/func7)
├── PC.sv                  # Program counter with stall and external write support
├── Decoder.sv             # Instruction decoder (R/I/S/B/J/U-type)
├── ALU.sv                 # Arithmetic logic unit (ADD, SUB, AND, OR, XOR, SLT, LUI)
├── Branch.sv              # Branch/jump resolution (BEQ, BNE, BLT, BGE, JAL, JALR)
├── RegFile.sv             # 32-entry register file with WB→ID bypass
├── IMem.sv                # Instruction memory (initialized from IMem.dat)
├── DMem.sv                # Data memory (initialized from DMem.dat)
├── IOCtrl.sv              # Memory-mapped IO controller (LED, OLED, buttons)
├── ClockDivider.sv        # 4x clock to 1x clock divider
├── CPU.sv                 # Single-cycle CPU (non-pipelined, for reference)
├── pipeCPU.sv             # 5-stage pipeline CPU (main implementation)
├── Main.sv                # Top-level module (CPU + memories + IO)
├── MainSim.sv             # Verilator simulation testbench
├── Makefile               # Build and simulation targets
├── pipeRegisters/
│   ├── IF_IDRegister.sv   # IF/ID pipeline register
│   ├── ID_EXRegister.sv   # ID/EX pipeline register
│   ├── EX_MEMRegister.sv  # EX/MEM pipeline register
│   └── MEM_WBRegister.sv  # MEM/WB pipeline register
├── IMem.dat               # Instruction memory image (hex)
└── DMem.dat               # Data memory image (hex)
```

## Memory Map

| Address Range | Region | Description |
|---------------|--------|-------------|
| `0x0000`–`0x7FFF` | Data Memory | 8192-word (32KB) data storage |
| `0x8000` | IO | Sort finish flag |
| `0x8004` | IO | Sort count |
| `0x8008` | IO | LED lamp |
| `0x800C` | IO | Sort start |
| `0x8010`–`0x8018` | IO | Button inputs (BTNU, BTND, BTNC) |
| `0x801C` | IO | Cycle counter |

## Getting Started

### Prerequisites

- [Verilator](https://verilator.org/) (v5.x recommended)
- [GTKWave](https://gtkwave.sourceforge.net/) (optional, for waveform viewing)
- GNU Make

### Build and Simulate

```bash
# Build
make clean
make

# Run simulation
make sim

# View waveform (optional)
make view
```

### Test Program: Bubble Sort

The included `IMem.dat` and `DMem.dat` implement a bubble sort of 5 integers.

**Initial data**: `{5, 4, 3, 2, 1}`
**Expected result**: `{1, 2, 3, 4, 5}`

To verify, add the following to `MainSim.sv` before `$finish`:

```systemverilog
$display("data[0] = %0d", main.dmem.mem[0]);
$display("data[1] = %0d", main.dmem.mem[1]);
$display("data[2] = %0d", main.dmem.mem[2]);
$display("data[3] = %0d", main.dmem.mem[3]);
$display("data[4] = %0d", main.dmem.mem[4]);
```

### Writing Custom Programs

Instruction memory (`IMem.dat`) and data memory (`DMem.dat`) are loaded via `$readmemh` at simulation start. Each line is a 32-bit hex value. Instructions follow standard RV32I encoding.

## FPGA Synthesis

The design targets Xilinx FPGAs using Vivado. The `Makefile` includes Vivado simulation and synthesis targets:

```bash
make vivado-sim       # Vivado behavioral simulation
make vivado-sim-gui   # Vivado simulation with GUI
make vivado           # Open Vivado project
```

## Acknowledgements

Developed as part of computer architecture practice at the Shioya Laboratory, Graduate School of Information Science and Technology, the University of Tokyo.
