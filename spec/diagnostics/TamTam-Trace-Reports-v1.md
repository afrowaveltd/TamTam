# TamTam Trace Reports (v1)

## 1. Purpose
This document defines a **recommended tracing and reporting mechanism** for TamTam packets.

Trace reports allow observing the **full lifecycle and route** of a packet across Stations and Dispatchers.
This mechanism is **optional**, implementation-level, and does **not change core protocol semantics**.

---

## 2. Scope and Non‑Goals

**In scope**:
- on‑demand packet tracing
- per‑hop reporting
- live or offline route reconstruction

**Out of scope**:
- guaranteed delivery of trace reports
- payload content logging
- security/audit policy

Trace is diagnostic, not transactional.

---

## 3. Activation

Tracing is activated when the original packet carries:
- `TraceRequested` flag in the header **or**
- an equivalent trace directive in payload (implementation choice)

Stations that do not support tracing simply ignore the request.

---

## 4. Trace Report Transport

Trace information is transmitted as **regular TamTam packets** sent to a dedicated service.

### 4.1 Trace Service Port

- **RecipientKind**: `Service`
- **RecipientId**: `0`
- **RecipientPort**: `TRACE_REPORT`

The concrete numeric value of `TRACE_REPORT` is reserved by convention.

---

## 5. Trace Report Packet

Trace reports are sent as `CONTROL` packets.

### 5.1 Trace Key
Each report must include a correlation key identifying the traced packet:

- `RouteId`
- `SenderId`
- `RequestId`
- `PacketType`

Together these uniquely identify a logical packet flow.

---

## 6. Trace Event Payload (Recommended)

Minimal recommended payload fields:

- `EventType` (enum)
- `NodeId` (StationId of reporting node)
- `Timestamp` (local, monotonic or wall‑clock)

Optional fields:
- `NextHop`
- `ReasonCode`
- `QueueDepth`
- `CapacityHint`

Payload format is implementation‑defined but should be stable.

---

## 7. Event Types (Recommended)

| EventType | Meaning |
|----------:|--------|
| RECEIVED | Packet received by node |
| FORWARDED | Packet forwarded to another node |
| CLAIMED | Packet accepted for processing |
| BUSY | Node unable to accept packet |
| ACK_SENT | ACK generated |
| RETRY_SCHEDULED | Retry planned |
| DROPPED | Packet dropped |
| DONE | Processing completed |

Implementations may extend this list.

---

## 8. Performance Rules

- Trace reports must **never block** packet forwarding or processing.
- If trace buffers are full, reports may be dropped.
- Trace queues should be bounded.

Trace reliability is intentionally best‑effort.

---

## 9. Collection Models

Two common deployment models:

### 9.1 Coordinator Collection
Trace reports are sent to the Coordinator associated with `RouteId`.

### 9.2 Dedicated Trace Station
A separate Station provides the `TRACE_REPORT` service for collection and visualization.

Both models are compatible.

---

## 10. Rationale

Using standard TamTam packets for trace reporting:
- avoids special channels
- keeps tracing observable and debuggable
- allows live visualization (Playground, UI)

Trace is designed to be **visible, optional, and cheap**.

---

End of document.

