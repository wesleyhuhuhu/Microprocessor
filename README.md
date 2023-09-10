# Microprocessor
## A simple microprocessor that is capable of running programs in the programs folder
The processor is written in SystemVerilog, and the assembler is written in Python
This microprocessor is a register register architecture, and stores output into memory.
## The supported instructions:
* Logical Shift Left
* Logical Shift Right
* AND
* OR
* XOR
* ADD
* SUB
* EOR
* NOT
* SET
* MOV
* BRN (branches, loops, and functions)

## Sample instruction:
    SET  0                          # Load immediate 0 into RF
    MOV R4, RF
    SET  1                          # Load immediate 1 into RF
    MOV R5, RF                     
    SET  30
    MOV R6, RF
