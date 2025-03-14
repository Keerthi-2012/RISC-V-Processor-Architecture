# RISC-V Processor Architecture Design

## Overview
This project implements a RISC-V processor in Verilog with both sequential and pipelined execution models. The design demonstrates fundamental concepts in computer architecture including instruction execution, pipelining, and hazard management.

## Architecture Features
- **Sequential Execution Model**: Single-cycle processor implementation
- **5-Stage Pipelined Execution**: Enhanced throughput with parallel instruction processing
- **Data Hazard Management**: Forwarding and stall mechanisms
- **Control Hazard Handling**: Branch prediction and pipeline flushing

## Execution Pipeline
The pipelined implementation consists of five classic stages:

1. **IF (Instruction Fetch)**
   - Fetches instruction from instruction memory
   - Updates program counter (PC)

2. **ID (Instruction Decode)**
   - Decodes instruction to determine operation
   - Reads register values
   - Generates control signals

3. **EX (Execute)**
   - Performs ALU operations
   - Calculates memory addresses for load/store
   - Computes branch targets and conditions

4. **MEM (Memory Access)**
   - Performs memory read/write operations
   - Resolves final branch outcomes

5. **WB (Write Back)**
   - Writes results back to register file

## Hazard Management
### Data Hazards
- **Forwarding**: Implements data forwarding from EX/MEM and MEM/WB stages to handle read-after-write (RAW) hazards
- **Pipeline Stalls**: Implemented for cases where forwarding is insufficient

### Control Hazards
- **Branch Prediction**: Simple static prediction (predict not taken)
- **Pipeline Flushing**: Flushes pipeline stages on branch misprediction

## Implementation Challenges
- **Sign Extension**: Proper sign extension for immediate values across different instruction formats
- **PC Update Logic**: Accurate PC updating for branch and jump instructions
- **Hazard Detection**: Identifying and resolving data and control dependencies
- **Memory Alignment**: Ensuring proper alignment for memory operations

## Files Included
* `sequential/` - Contains Verilog files for sequential processor implementation.
* `pipelined/` - Contains Verilog files for pipelined processor.

### Prerequisites
- Icarus Verilog or other Verilog simulator
- GTKWave (for waveform viewing)


## Performance Analysis
The pipelined implementation offers significant performance improvements over the sequential design:

- **Sequential Model**: 1 instruction per N clock cycles (where N is the number of stages)
- **Pipelined Model**: Approaches 1 instruction per clock cycle under ideal conditions
- **CPI (Cycles Per Instruction)**: Typically between 1.2-1.5 for the pipelined implementation with hazards

