# TamTam
**Minimalistic Realtime Communication Engine**  
with **Safari Bus** transport model 🐘🚌

TamTam is a low-level, platform-agnostic communication engine designed for reliable message passing, large data transfers, and real-time streaming across heterogeneous systems, from modern servers to legacy NAS devices and bare-metal environments.

TamTam is not a framework.  
TamTam is a **bus**.

---

## Core Philosophy
- **Minimalistic, but not limiting**
- **Byte-level first** (payload is always raw bytes)
- **Disk-first, RAM-optional** (works on low-memory systems)
- **Deterministic behavior**
- **Everything is a message**
- **One architecture, many transports** (network, serial, IPC, file, memory)

TamTam can run over:
- TCP / UDP
- WebSocket
- Serial line
- Shared memory
- File-based transport
- Custom embedded links

---

## Safari Bus
TamTam uses a **three-lane transport model** called **Safari Bus**.

### 🟢 Fast Lane (Couriers & Motorbikes)
- Single-packet messages
- ACK required
- Low latency
- Control messages, chat, TTY input, ACK/ERR/AUDIT
- Always prioritized

### 🟡 Bulk Lane (Cargo Trucks)
- Multi-packet (segmented) messages
- ACK required
- Large data transfers (IMG, dataswap, big objects)
- Disk-first processing
- Fairness enforced

### 🔵 Stream Lane (Flow)
- No ACK
- Terminator-controlled lifetime (TTL / phase)
- Video, audio, live logs, stdout streaming
- Receiver drains immediately
- Limited lifetime (default: 3–5 cycles)

---

## Cycle Model (Tram Stop Model)
Each TamTam cycle behaves like a tram stop:

1. **Deliver phase**
   - Messages exit the bus
   - Middleware runs first (Logger, Reporter)
   - Application handlers consume messages

2. **Commit phase**
   - New messages, ACKs, resends enter the bus
   - No handler may block the cycle

Minimum latency is **one cycle**.  
Cycle speed is adaptive and controlled by the orchestrator.

---

## Roles & Processing Order
Roles are processed **from lowest priority to highest**, with **Orchestrator always last**.

| Role ID | Role |
|------|------|
| 0 | Orchestrator |
| 1 | Logger (middleware tee) |
| 2 | Reporter / Metrics |
| 3–10 | System services |
| 11–100 | Middleware |
| 101+ | Application / Translation |

---

## Port Architecture
Ports are logical service identifiers, not network ports.

### Reserved Port Ranges
- **0** – Orchestrator
- **1–10** – System services (Logger, Reporter, Discovery)
- **11–100** – Middleware
- **101–1000** – Language translation ports
- **1001–1100** – AI translation ports (fallback / on-demand)

### Translation Example
- `port 150` → Translate to Czech
- `port 234` → Translate to French
- `port 1001` → AI Translator (Ollama fallback)

If no server handles a language port, the request is routed to AI.

---

## Reliability Model
- ACK for **all messages except stream**
- Multipart ACK supported
- Resend & audit supported
- Dead-man activity detection
- Automatic priority aging (no starvation)

---

## Stream Model (with Terminator)
Streams are multicast-like and managed in two phases:

1. **Discovery**
   - Orchestrator discovers listeners
   - Assigns one node as **Terminator**

2. **Flow**
   - Stream frames circulate
   - Terminator controls lifecycle (TTL / phase)
   - Frames removed deterministically

Each receiver keeps a small cache of recently seen stream tokens.

---

## Payload Format
TamTam transports **raw bytes** only.

Optionally, payloads may use **TPF – TamTam Payload Format**:
- Canonical binary encoding
- Schema-driven
- Endianness defined
- Cross-language (C ↔ C#)
- Enables `SendMessage<T>` safely

Transport and payload are strictly separated.

---

## Logging, Telemetry & Diagnostics
Telemetry is just another message flow.

### System Ports
- **Logger (1)** – log & forward middleware
- **Reporter (2)** – metrics & progress reporting

Supports:
- Bus stats
- Node stats
- Transfer progress (percent, rate, ETA)
- Debug tracing
- SignalR / HTTP bridges

---

## Fairness & Backpressure
- Max consecutive messages per recipient (default: 10)
- Max bus share per service (default: 80%)
- Reserved capacity for overload recovery (default: 20%)
- Slow consumers never block the system

---

## Supported Use Cases
- Reliable messaging
- Large file / disk image transfer (IMG)
- Data swap between systems
- Live video / audio streaming
- Distributed translation orchestration
- Chat (user / group / broadcast)
- Remote terminal (stdin/stdout over TamTam)
- Monitoring & diagnostics
- Embedded / legacy system communication

---

## Repository Structure
```text
/ TamTam
├── spec/
│   ├── model/
│   │   ├── SafariBus-v1.md
│   │   ├── Cycle-v1.md
│   │   ├── Fairness-v1.md
│   │   └── Stream-v1.md
│   ├── payload/
│   │   └── TPF-v1.md
│   ├── registry/
│   │   ├── Ports-v1.md
│   │   └── LanguagePorts-v1.md
│   └── usecases/
│       ├── TranslationOrchestration-v1.md
│       └── ChatAndTTY-v1.md
│
├── src/
│   ├── c/
│   └── dotnet/
│
├── examples/
│   ├── img_swap/
│   ├── translation_bus/
│   └── chat_and_tty/
│
└── README.md
```

---

## Examples (minimum set)
### 1️⃣ IMG Swap
- Two disk images exchanged block-by-block
- Bulk lane + ACK
- Disk-first
- Progress reported via Reporter

### 2️⃣ Translation Bus
- Multiple LibreTranslate servers
- Language ports 101–1000
- AI fallback on 1001+
- Yield-style result streaming

### 3️⃣ Chat & Remote TTY
- User / group / broadcast ports
- Live stdout streaming
- Keyboard input over Fast Lane

---

## Project Status
This repository currently contains:
- **Architecture & protocol design**
- **Normative specifications**
- **Reference roadmap**

Reference implementations (C / C#) follow the spec strictly.

---

## Final Note
TamTam is intentionally **simple at the wire level**  
and **powerful at the system level**.

It is designed to survive:
- slow hardware
- bad networks
- long runtimes
- real production chaos

> **If it can survive a safari, it can survive production.** 🐘🚌

