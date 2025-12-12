# TamTam

**A minimalistic, resilient, transport-agnostic communication engine built around deterministic message circulation.**

**TamTam** is a resilient, transport-agnostic communication system designed around a simple but powerful idea:
messages circulate in controlled cycles, nothing is lost until work is finished, and the system remains usable even on very limited hardware.

TamTam is built to be:
- minimalistic,
- deterministic,
- highly portable,
- and fully documented down to the last bit.

It can run on servers, embedded devices, old NAS machines, browsers, or inside a single process.

---

## Mental Model

TamTam follows a **roundabout model**:

- messages are **cars**
- nodes are **roads leading to cities**
- ports are **lanes**
- the roundabout is the **communication bus**
- the orchestrator is the **traffic officer**
- acknowledgements are **proof that the car passed safely**

Every message enters the roundabout, is routed according to its destination, and leaves only when its job is confirmed as done.

Nothing disappears silently.

---

## Core Concepts

### Node
A node is any participant in the system.
A node may send messages, receive messages, and expose services.

Each node contains:
- a **disk queue** (persistent, unlimited by RAM),
- a **RAM buffer** (small, controlled working set),
- a **transport adapter** (TCP, WebSocket, file, pipe, in-memory),
- a set of **port handlers** (services).

---

### Orchestrator
The orchestrator is the **gate** of the roundabout.

It:
- controls message circulation cycles,
- schedules traffic fairly,
- requests acknowledgements and resends,
- enforces timeouts and audits.

The orchestrator **never stores payload data**.
It only works with lightweight descriptors.

Security and authentication are handled **outside** of TamTam.

---

### Port
A port represents a **service**, not a network port.

- Each service listens on a port number.
- Ports define routing.
- Broadcast, group and unicast are all supported.

---

### Message and Parts
A **message** is a logical request or response.

If the payload is large, the message is automatically split into **parts**:
- all parts have the same size (except the last),
- parts are acknowledged individually,
- parts are reassembled disk-first.

This allows transfers of extremely large data even with very small RAM.

---

## Reliability Principles

TamTam follows one strict rule:

> **No data may be removed from memory or disk until the operation is fully confirmed.**

- acknowledgements are explicit,
- resends are deterministic,
- failures always end in a known state.

A physical disconnect may interrupt a request.
Nothing else should.

---

## Streaming Mode

TamTam supports streaming messages:

- stream packets are broadcast-style,
- they do not require acknowledgements by default,
- each stream packet has a limited lifetime measured in **roundabout passes (TTL)**.

This prevents infinite circulation while keeping the system simple.

---

## Transport-Agnostic Design

TamTam does not depend on any specific transport.

It can run over:
- TCP
- WebSocket
- Unix domain sockets
- named pipes
- shared memory
- files and removable media
- in-memory queues

The same protocol logic applies everywhere.

---

## Specification and Portability

TamTam is designed to be implemented in **any programming language**.

The protocol is:
- precisely specified,
- byte-level documented,
- supported by test vectors.

A moderately experienced programmer should be able to implement TamTam without using any official library.

---

## Typical Use Cases

- internal application event bus
- microservice communication without heavy brokers
- embedded and NAS devices
- air-gapped environments
- large data transfers with minimal RAM
- real-time dashboards over WebSocket
- distributed orchestration systems

---

## Project Structure (planned)

- **Protocol specification** (wire format, message lifecycle)
- **Reference implementations** (C, C#)
- **Additional ports** (Python, JavaScript)
- **Test vectors and benchmarks**
- **Telemetry and diagnostics tools**

---

## Philosophy

TamTam values:
- clarity over magic,
- determinism over guesswork,
- resilience over speed,
- simplicity over convenience.

If you can send a signal and receive an echo, TamTam can work there.

---

🥁  
*TamTam calls. Someone answers.*

