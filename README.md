# TamTam
**Minimalistic Realtime Communication Engine**  
with **Safari Bus** transport model 🐘🚌

**A minimalistic, resilient, transport-agnostic communication engine built around deterministic message circulation and explicit interchange routing.**

**TamTam** is an open-source communication system built around a simple but powerful idea:

> Messages circulate in controlled cycles, routing is explicit, nothing is lost until work is finished,
> and the system remains usable even on very limited or highly diverse environments.

TamTam is designed to run:

* across heterogeneous runtimes,
* on servers, embedded devices, old NAS machines,
* inside browsers, containers, or a single process,
* and across different programming languages.

It is minimalistic, deterministic, highly portable, and documented down to the byte level.

---

## Safari Bus
TamTam uses a **three-lane transport model** called **Safari Bus**.

TamTam follows a **roundabout (interchange) model**:

* messages are **cars**
* links are **local roads**
* the interchange is the **roundabout**
* orchestrators are **transfer stations and traffic officers**
* transports are **vehicles**
* acknowledgements are **proof of safe passage**

Messages circulate until their work is explicitly confirmed as done.
Nothing disappears silently.

---

## Core Architecture

### Link

A **link** represents a local communication domain.

* Nodes within a link communicate directly.
* Each link is isolated in responsibility.
* A link does not know about other links.

Every link has exactly one **orchestrator**.

---

### Orchestrator

The **orchestrator** is the natural dispatcher and transfer station of a link.

It:

* manages local message circulation,
* decides whether a message is local or roaming,
* connects the link to the **interchange (roundabout)**,
* performs routing decisions (ring-forwarding or direct delivery),
* enforces fairness, retries, timeouts, and audits.

An orchestrator:

* never interprets payload data,
* operates on lightweight descriptors only,
* may host multiple logical links internally,
  each exposed as an independent transfer station.

Other links never need to know whether orchestrators share a process, machine, or runtime.

---

### Interchange (Roundabout)

The **interchange** is a shared routing environment where orchestrators meet.

* It is transport-agnostic.
* It does not inspect payloads.
* It does not assume homogeneous implementations.

Routing strategies:

* **Ring-forwarding** for bootstrap, resilience, and unknown topology.
* **Direct delivery** when routes are known.

The choice of strategy is a **policy decision of the orchestrator**, never encoded in the packet.

---

### Node

A **node** is any participant within a link.

A node may:

* send messages,
* receive messages,
* expose services through logical ports.

Nodes do **not** know about the interchange.

---

### Port

A **port** represents a service, not a network socket.

* Ports define routing targets.
* Unicast, group, and broadcast are supported.
* Port semantics are local to a link.

### Translation Example
- `port 150` → Translate to Czech
- `port 234` → Translate to French
- `port 1001` → AI Translator (Ollama fallback)

## Messages and Parts

A **message** is a logical request or response.

Large payloads are automatically split into **parts**:

* fixed-size chunks (except the last),
* acknowledged individually,
* reassembled disk-first.

This allows reliable transfer of extremely large data with minimal RAM.

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

* acknowledgements are explicit,
* retries are deterministic,
* failures always end in a known state.

A physical disconnect may interrupt communication.
Nothing else should.

---

## Payload Format
TamTam transports **raw bytes** only.

Optionally, payloads may use **TPF – TamTam Payload Format**:
- Canonical binary encoding
- Schema-driven
- Endianness defined
- Cross-language (C ↔ C#)
- Enables `SendMessage<T>` safely

* stream packets are broadcast-style,
* acknowledgements are optional,
* lifetime is bounded by **interchange passes (TTL)**.

---

## Transport-Agnostic by Design

### System Ports
- **Logger (1)** – log & forward middleware
- **Reporter (2)** – metrics & progress reporting

It can run over:

* UDP / TCP
* WebSocket / SignalR
* Unix domain sockets
* named pipes
* shared memory
* files and removable media
* in-memory queues

The same protocol rules apply everywhere.

---

## Open Source & Multi-Language Ecosystem

TamTam is **fully open source**.

* The protocol is precisely specified and byte-documented.
* Anyone may implement TamTam in any language.
* Official **C# implementations** serve as reference and interoperability anchors.
* Community implementations are encouraged in other languages and environments.

The ecosystem is designed so that:

* new orchestrators,
* transports,
* bridges,
* diagnostic tools

can be added without modifying the core specification.

## Fairness & Backpressure
- Max consecutive messages per recipient (default: 10)
- Max bus share per service (default: 80%)
- Reserved capacity for overload recovery (default: 20%)
- Slow consumers never block the system

---

## Specification & Interoperability

TamTam is designed to be implemented **without any official library**.

The project provides:

* normative protocol specifications,
* interoperability test vectors,
* reference orchestrators,
* public testing environments (planned).

If you can send bytes and receive bytes, TamTam can run there.

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

* distributed event buses
* microservice communication without heavy brokers
* embedded and NAS devices
* air-gapped or constrained environments
* large data transfers with minimal RAM
* real-time dashboards
* orchestration and coordination systems

---

## Project Status
This repository currently contains:
- **Architecture & protocol design**
- **Normative specifications**
- **Reference roadmap**

* **Protocol specification**
* **Reference orchestrators (C#, C)**
* **Community orchestrators and tools**
* **Transport adapters**
* **Interoperability test suites**
* **Public interchange playgrounds**

---

## Philosophy

TamTam values:

* clarity over magic,
* determinism over guesswork,
* resilience over speed,
* architecture over convenience.

If two systems can exchange bytes, TamTam can connect them.

It is designed to survive:
- slow hardware
- bad networks
- long runtimes
- real production chaos

🥁
*TamTam calls. Anyone may answer.*
