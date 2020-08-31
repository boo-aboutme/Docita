# Instructions

## Programming model

### Global registers

|11\ 10\ \ 9\ \ 8\ \ 7\ \ 6\ \ 5\ \ 4\ \ 3\ \ 2\ \ 1\ \ 0|\ \ |
|-------------------------------------------------------:|---:|
|                                                        |    |

### Special registers



|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 0|rd|rd|rd| 0| 0| 0|rs|rs|rs|

## Instructions in alphabetical order

### 1.  ADD - Add two registers

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 0|rd|rd|rd| 0| 0| 0|rs|rs|rs|

ADD *rd*, *rs*

rd <- rd + rs

Adds registers *rd* and *rs*, stores the result to *rd*

### 2.  AND - And two registers

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 0|rd|rd|rd| 0| 1| 1|rs|rs|rs|

### 3.  BAL - Branch always

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 0| 0| 0|imm|imm|imm|imm|imm|imm|

### 4.  BGE - Branch on greater or equal

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 1| 0| 0|imm|imm|imm|imm|imm|imm|

### 5.  BGEU - Branch on greater or equal unsigned (unimplemented)

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 1| 1| 0|imm|imm|imm|imm|imm|imm|

### 6.  BGT - Branch on greater

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 0| 1| 1|imm|imm|imm|imm|imm|imm|

### 7.  BGTU - Branch on greater unsigned (unimplemented)

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 1| 0| 1|imm|imm|imm|imm|imm|imm|

### 8.  BNZ - Branch on not zero

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 0| 1| 0|imm|imm|imm|imm|imm|imm|

### 9.  BZ - Branch on zero

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 0| 0| 0| 1|imm|imm|imm|imm|imm|imm|

### 10. CLR - Clear register
### 11. CMP - compare two registers

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 0|rd|rd|rd| 0| 1| 0|rs|rs|rs|

### 12. DECR - Decrement a register by an immediate

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 1|rd|rd|rd| 0| 0| 1|imm|imm|imm|

### 13. HALT - Halt

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 1| 0| 0| 0| 1| 1| 1| 0| 0| 0|

### 14. INCR - Increment a register by an immediate

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 1|rd|rd|rd| 0| 0| 0|imm|imm|imm|

### 15. JALA - Jump to absolute address and link

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 1|rd|rd|rd| 0| 0| 0|rs|rs|rs|

### 16. JALP - Jump to relative address and link (unimplemented)

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 0| 1|rd|rd|rd| 0| 0| 1|rs|rs|rs|

### 17. LDA - Load from absolute address

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 0|rd|rd|rd| 0| 0| 0|rs|rs|rs|

### 18. LDP - Load from relative address (unimplemented)

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 0|rd|rd|rd| 0| 0| 1|rs|rs|rs|

### 19. MOVE - Copy fro a register to a register

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 1| 1| 0|rs|rs|rs|

### 20. NEG - Get two's complement of a register

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 1| 0| 1|rs|rs|rs|

### 21. NOP - No operation
### 22. NOT - Negate all bits of a register

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 1| 0| 0|rs|rs|rs|


### 23. OR - Or two registers

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 0|rd|rd|rd| 1| 0| 0|rs|rs|rs|

### 24. RDPC - Read program counter

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 1|rd|rd|rd| 1| 0| 1| 0| 0| 0|

### 25. RET - Return from call

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 1| 0| 0| 0| 1| 1| 0|rs|rs|rs|

### 26. SEXT - Sign extend

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 1| 1| 1|rs|rs|rs|

### 27. SIHI - Set immediate high

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 1| 1|rd|rd|rd|imm|imm|imm|imm|imm|imm|

### 28. SILO - Set immediate low 

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 1| 1| 0|rd|rd|rd|imm|imm|imm|imm|imm|imm|

### 29. SLL - Shift left logical

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 0| 1| 0|rs|rs|rs|

### 30. SRA - Shift right arithmetic

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 0| 0| 1|rs|rs|rs|

### 31. SRL - Shift right logical

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 1|rd|rd|rd| 0| 0| 0|rs|rs|rs|

### 32. STA - Store to absolute address

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 0|rd|rd|rd| 0| 1| 0|rs|rs|rs|

### 33. STP - Store to relative address (unimplemented)

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 1| 0|rd|rd|rd| 0| 1| 1|rs|rs|rs|

### 34. SUB - Subtract from a register

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 0|rd|rd|rd| 0| 0| 1|rs|rs|rs|

### 35. XOR - Exclusive or

|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0|
|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 0| 0| 0|rd|rd|rd| 1| 0| 1|rs|rs|rs|
