# TamTam Header (v1)

## 1. Purpose
This document defines the **TamTam v1 header** binary layout.
The header is designed for:
- deterministic parsing in C and Assembly
- safe serialization without implicit padding
- routing across links via `RouteId`
- reliable acknowledgements and retransmission via immutable `SenderId`

This document is **normative**.

---

## 2. Terminology

- **Station**: A TamTam node/endpoint participating in message exchange.
- **Drum**: A symbolic alias for Station (used in diagrams and narrative).
- **ControlPort**: A required port of every Station used for ACK/control/retransmit.
- **ServicePort**: Optional ports for services (may be shared by many Stations).

---

## 3. Binary Conventions

All conventions in `TamTam-Binary-Conventions-v1.md` apply.
In particular:
- all multi-byte integers are **little-endian**
- no implicit padding is allowed
- UTF-8 is used for textual payloads (payload-level)

---

## 4. Header Overview

### 4.1 Fixed Header
TamTam v1 uses a **fixed-length header** of **32 bytes**.

- The header is always present.
- Payload begins immediately after the header.

### 4.2 Minimal Parsing Requirement
A receiver must be able to:
- validate the header format (magic/version)
- read routing and addressing fields
- determine payload length
- determine whether ACK/control behavior is required

---

## 5. Field Layout (32 bytes)

All offsets are **byte offsets** from the start of the header.

| Offset | Size | Type | Name | Description |
|-------:|-----:|------|------|-------------|
| 0 | 2 | u16 | Magic | Constant `0x5454` (ASCII 'TT' in little-endian) |
| 2 | 1 | u8 | Version | Protocol version. For this spec: `1` |
| 3 | 1 | u8 | HeaderLength | Header length in bytes. For v1: `32` |
| 4 | 1 | u8 | PacketType | Packet type (see §6) |
| 5 | 1 | u8 | Flags | Bit flags (see §7) |
| 6 | 2 | u16 | RouteId | Link identifier (maps to exactly one Coordinator) |
| 8 | 8 | u64 | SenderId | Immutable sender identity (Station ID) |
| 16 | 1 | u8 | RecipientKind | Recipient kind (see §8) |
| 17 | 1 | u8 | Reserved0 | Must be `0` in v1 (for future use) |
| 18 | 2 | u16 | RecipientPort | Recipient port (ControlPort or ServicePort) |
| 20 | 8 | u64 | RecipientId | Recipient identity (Station ID). `0` for Service-cast / Group-cast |
| 28 | 2 | u16 | PayloadLength | Payload length in bytes (0..65535) |
| 30 | 2 | u16 | RequestId | Correlation id for ACK/RESULT/retries (wrap allowed) |

Notes:
- `RecipientId == 0` means "not a specific Station" (service/group selection by routing policy).
- `RecipientPort` is always present and always meaningful.

---

## 6. PacketType (u8)

TamTam v1 defines these packet types:

| Value | Name | Description |
|------:|------|-------------|
| 0x01 | REQUEST | A request expecting processing (often expects ACK) |
| 0x02 | RESULT | Response to a REQUEST (matches by RequestId + SenderId) |
| 0x03 | ACK | Acknowledgement of receipt/processing stage (see §9) |
| 0x04 | CONTROL | Internal control message (claim, busy, health, discovery) |
| 0x05 | STREAM | Stream segment (ACK policy differs; see §9) |

Implementations must treat unknown PacketType values as unsupported.

---

## 7. Flags (u8)

Flags are bitwise.

| Bit | Mask | Name | Meaning |
|----:|-----:|------|---------|
| 0 | 0x01 | AckRequired | Receiver should send ACKs for this packet |
| 1 | 0x02 | IsRetry | Sender marks this packet as a retry of the same RequestId |
| 2 | 0x04 | IsFragment | Payload is a fragment/chunk of a larger message |
| 3 | 0x08 | Reserved | Must be 0 in v1 |
| 4 | 0x10 | Reserved | Must be 0 in v1 |
| 5 | 0x20 | Reserved | Must be 0 in v1 |
| 6 | 0x40 | Reserved | Must be 0 in v1 |
| 7 | 0x80 | Reserved | Must be 0 in v1 |

Rules:
- For non-stream messages, `AckRequired` is typically set.
- For STREAM packets, `AckRequired` may be unset; ACK can be periodic/block-based (implementation policy).

---

## 8. RecipientKind (u8)

| Value | Name | Meaning |
|------:|------|---------|
| 0x01 | Station | A specific Station (RecipientId must be non-zero) |
| 0x02 | Group | A group recipient (RecipientId may be group id; or 0 for policy-selected group) |
| 0x03 | Service | A service recipient (RecipientId must be 0; RecipientPort identifies service) |
| 0x04 | Coordinator | The Coordinator of RouteId (RecipientId must be 0; RecipientPort must be 0) |

Notes:
- **Service-cast**: `RecipientKind=Service`, `RecipientId=0`, `RecipientPort=ServicePort`.
- **Direct unicast**: `RecipientKind=Station`, `RecipientId=<stationId>`, `RecipientPort=<controlPort or servicePort>`.

---

## 9. ACK and Reliability (v1 policy)

### 9.1 ACK Addressing
ACK packets must be addressed to:
- `RecipientId = SenderId` of the original packet
- `RecipientKind = Station`
- `RecipientPort = ControlPort` of that Sender Station

The sender identity is immutable and enables return-to-sender routing.

### 9.2 ACK Semantics
TamTam v1 defines a minimal ACK model:

- `ACK` confirms **receipt and/or accepted processing**.
- The exact stage is conveyed by a CONTROL payload or future flags.

For TestLab v1 we use:
- ACK means "received and accepted into processing queue".
- A later RESULT (or CONTROL "DONE") confirms completion.

### 9.3 Retransmission
If `AckRequired` is set and ACK is not received within a timeout:
- sender may resend the packet with the same `RequestId`
- sender must set `IsRetry`

Receivers should deduplicate by:
- (`SenderId`, `RequestId`, `PacketType`) within a time window

---

## 10. Fragmentation (Header-level)

Fragmentation is indicated by `IsFragment`.

TamTam v1 does not mandate a specific fragment metadata format in the core header.
Fragment ordering and assembly metadata are carried in the **payload prefix** for fragment-capable packet types.

Recommended minimal fragment payload prefix (for `IsFragment`):
- `u64 MessageId`
- `u32 TotalLength`
- `u32 ChunkOffset`
- `u16 ChunkLength`

(This prefix is recommended for TestLab. A separate spec may formalize it.)

---

## 11. Parsing Rules

A receiver must validate:
1. `Magic == 0x5454`
2. `Version == 1`
3. `HeaderLength == 32`
4. `PayloadLength` does not exceed the received buffer

If validation fails, the frame must be dropped.

---

## 12. Forwarding Rules (Header-level)

Forwarders/Dispatchers must:
- never rewrite `SenderId`
- preserve `RequestId`
- decrement hop/TTL if/when such a field is introduced in a future version

TamTam v1 does not include a TTL field yet; TestLab implementations should enforce loop prevention at the routing layer.

---

## 13. Rationale Notes (Non-normative)

- Fixed 32-byte header keeps parsing trivial in Assembly.
- `RouteId` anchors the message to a link/Coordinator.
- `RecipientKind + RecipientPort + RecipientId` supports:
  - unicast
  - group-cast
  - service-cast
  - coordinator addressing

---

End of document.

