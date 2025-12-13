# TamTam

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

## Mental Model

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

---

## Messages and Parts

A **message** is a logical request or response.

Large payloads are automatically split into **parts**:

* fixed-size chunks (except the last),
* acknowledged individually,
* reassembled disk-first.

This allows reliable transfer of extremely large data with minimal RAM.

---

## Reliability Principles

TamTam follows one strict rule:

> **No data may be removed from memory or disk until the operation is fully confirmed.**

* acknowledgements are explicit,
* retries are deterministic,
* failures always end in a known state.

A physical disconnect may interrupt communication.
Nothing else should.

---

## Streaming Mode

TamTam supports streaming messages:

* stream packets are broadcast-style,
* acknowledgements are optional,
* lifetime is bounded by **interchange passes (TTL)**.

This prevents infinite circulation while keeping the system simple.

---

## Transport-Agnostic by Design

TamTam does not depend on any specific transport.

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

## Typical Use Cases

* distributed event buses
* microservice communication without heavy brokers
* embedded and NAS devices
* air-gapped or constrained environments
* large data transfers with minimal RAM
* real-time dashboards
* orchestration and coordination systems

---

## Project Structure (planned)

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

---

🥁
*TamTam calls. Anyone may answer.*
