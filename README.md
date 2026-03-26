

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

> Broadcast Code (BC) is formed as `ESC + DATA` and handled at the sequencer level.

---

### 3. `Sequencer.v`

**Purpose:** Character scheduling and transmission control (sequential FSM)

**Functionality:**
- Determines the **next SpaceWire character to transmit** based on:
  - flow control requests (`SEND_FCT`, `SEND_BC`)
  - FIFO data availability
  - serializer status (`serial_busy`)
- Generates:
  - `char_type`
  - `data_byte`
  - `load` (initiates transmission)
  - `read_en` (FIFO read pulse)
  - `data_sent` (data acknowledgment pulse)


**Core Responsibilities:**

- **Character Prioritization:**
  - Broadcast Code (BC) → highest priority  
  - Flow Control Token (FCT)  
  - End of Packet (EOP/EEP)  
  - Data (N-Character)  
  - NULL (ESC + FCT)


- **Pending Request Handling:**
  - Accumulates multiple FCT requests (`FCT_pending`)
  - Handles broadcast requests (`BC_pending`)
  - Tracks end-of-packet condition (`eop_pending`)


- **Event-Driven FSM Execution:**
  - State transitions occur **once per transmission slot**
  - Controlled using a **request/token mechanism (`state_req`)**
  - Prevents:
    - multiple transitions during idle (`!serial_busy`)
    - skipping of states
    - unintended multiple decrements (e.g., `FCT_pending`)


- **Serializer Synchronization:**
  - Asserts `load` **only when `serial_busy = 0`**
  - Ensures:
    - stable inputs to serializer
    - no mid-transmission overwrites


- **FIFO Interface:**
  - Asserts `read_en` for **one clock cycle** when transmitting DATA
  - Uses `fifo_data[8]` to detect EOP condition


- **Output Control:**
  - Outputs are **state-driven**
  - Pulse signals (`read_en`, `data_sent`, `FCT_sent`) are generated using:
    - default-zero + conditional-one approach


**Key Design Characteristics:**

- Fully synchronous FSM
- Separation of:
  - next-state logic (combinational)
  - state update (event-gated sequential)
  - output logic (state-based)
- Avoids:
  - level-sensitive transitions
  - multi-cycle side effects
  - race conditions between control and data path


**Notes:**
- Broadcast Code (BC) is transmitted as:
  - `ESC` → `DATA (broadcast_code)`
- `FCT_pending` is decremented **exactly once per transmitted FCT**, aligned with state transition
- Designed to comply with **SpaceWire timing and ordering requirements**

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

### 6. `Flow_Control_Tx.v`

**Purpose:** Flow Control Token (FCT) generation for transmitter

**Functionality:**
- Generates FCTs based on receiver credit availability.
- Ensures compliance with SpaceWire flow control rules.
- Sends FCT after receiving sufficient room from the receiver.
- Prevents data transmission when credit is exhausted.
- Interfaces with sequencer to insert FCT characters into stream.
- Handles:
  - FCT request generation
  - FCT transmission acknowledgment
  - Credit counter management


---

### 7. `Flow_Control_Rx.v`

**Purpose:** Flow Control Token (FCT) handling for receiver

**Functionality:**
- Updates receive-side credit counter.
- Generates signals indicating when transmitter can send more data.
- Ensures no buffer overflow by controlling credit return rate.

### 6. `top_enc.v`

**Purpose:** Structural integration module

**Functionality:**
- Instantiates multiple signals 
- Contains minimal logic.
- Responsible only for signal routing and connectivity.
- Maintains modular and scalable architecture.

---
