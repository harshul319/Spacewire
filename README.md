

## Implemented Modules

### 1. `bit_en.v`

**Purpose:** Bit-rate enable generator

**Functionality:**
- Divides the system clock into transmission bit enable pulses.
- Generates a single-cycle `bit_en` pulse.
- Controls serializer shifting and DS encoding timing.
- Fully synchronous with reset support.

---

### 2. `character_builder.v`

**Purpose:** Character formatting logic (combinational)

**Functionality:**
- Constructs SpaceWire characters according to ECSS specification.
- Computes parity automatically.
- Packs bits for correct LSB-first transmission.
- Outputs:
  - `word[9:0]`
  - `length[3:0]`

**Supported character types:**
- `DATA` (N-Character, 10 bits)
- `FCT` (Flow Control Token, 4 bits)
- `EOP` (End of Packet, 4 bits)
- `EEP` (Error End of Packet, 4 bits)
- `ESC` (Escape, 4 bits)

> Broadcast Code (BC) is formed as `ESC + DATA` and handled at the scheduler level.

---

### 3. `character_scheduler.v`

**Purpose:** Character sequencing logic (sequential FSM)

**Functionality:**
- Decides which character to transmit.
- Ensures serializer loads only when not busy.
- Handles composite sequences (e.g., `ESC + DATA` for Broadcast Code).
- Keeps protocol control separate from formatting logic.

---

### 4. `Serializer.v`

**Purpose:** Parallel-to-Serial converter

**Functionality:**
- Accepts:
  - `word`
  - `length`
  - `load`
- Outputs:
  - `serial_bit`
  - `busy`
- Transmits **LSB-first**.
- Shifts only on `bit_en`.
- Fully synchronous design.

---

### 5. `Data_Strobe.v`

**Purpose:** SpaceWire Data-Strobe encoding

**Functionality:**
- Converts serialized bit stream into `DATA` and `STROBE` signals.
- Implements SpaceWire DS rule:
  - DATA changes when bit changes.
  - STROBE toggles when DATA does not change.
- Updates only when serializer is `busy` and `bit_en` is active.

---

### 6. `top_enc.v`

**Purpose:** Structural integration module

**Functionality:**
- Instantiates multiple signals 
- Contains minimal logic.
- Responsible only for signal routing and connectivity.
- Maintains modular and scalable architecture.

---
