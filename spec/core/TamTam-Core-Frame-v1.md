# TamTam – Core Frame Specification v1.0

## 1. Scope and Philosophy

This document defines the **TamTam Core Frame**.

The Core Frame is the lowest and most stable layer of the TamTam system. It specifies:
- the exact byte layout of a TamTam packet,
- how packet boundaries are determined,
- how integrity is verified,
- how payload length is defined and interpreted.

The Core Frame is:
- **transport-agnostic**,
- **payload-agnostic**,
- **routing-agnostic**.

Anything not explicitly defined here is considered **out of scope** and must be handled by higher layers.

---

## 2. Packet Overview

A TamTam packet consists of:
- a fixed-size header,
- an optional header extension (roaming only),
- an integrity byte,
- an explicit payload length field,
- a fixed-size payload block.

Two packet forms exist:

### 2.1 Local Packet
```
[ Header 3B ][ Integrity 1B ][ UsedLen 2B ][ PayloadBlock ]
```

### 2.2 Roaming Packet
```
[ Header 3B ][ Extension 2B ][ Integrity 1B ][ UsedLen 2B ][ PayloadBlock ]
```

The presence of the extension is controlled by a header flag.

---

## 3. Header Layout (3 Bytes)

### 3.1 Byte 0 – Message Kind

```
bits 7..4 : Class
bits 3..0 : Direction
```

#### Class
| Value | Meaning |
|------:|--------|
| 0x0 | System |
| 0x1 | Control |
| 0x2 | Data |
| 0x3 | Event |
| 0x4 | Response |
| 0xF | Reserved |

#### Direction
| Value | Meaning |
|------:|--------|
| 0x0 | Request |
| 0x1 | Reply |
| 0x2 | Broadcast |
| 0x3 | Signal |
| 0xF | Reserved |

---

### 3.2 Byte 1 – SizeId and Flags

```
bits 7..4 : SizeId
bits 3..0 : Flags
```

#### Flags (low nibble)
| Bit | Name | Meaning |
|----:|------|--------|
| 0 | BigMode | Payload block size is doubled |
| 1 | AckRequested | Explicit acknowledgement requested |
| 2 | Priority | Scheduler hint (high priority) |
| 3 | HasExt | Optional header extension present |

---

### 3.3 Byte 2 – ChannelId

- 8-bit unsigned value
- Identifies a logical routing channel within a link
- Interpretation is local to the receiving system

---

## 4. Optional Header Extension (Roaming)

If `HasExt = 1`, the header is immediately followed by:

```
[ DestOrchestratorId : 2 bytes ]
```

- Type: unsigned 16-bit integer
- Byte order: network order (big-endian)
- Identifies the destination orchestrator for inter-link routing

If `HasExt = 0`, no extension is present.

---

## 5. Integrity (CRC8)

### 5.1 Integrity Field

- Size: 1 byte
- Type: CRC8 checksum

### 5.2 CRC Input

The CRC8 value is computed over the following byte sequence, in order:

1. Header (3 bytes)
2. Optional Extension (0 or 2 bytes)
3. UsedLen field (2 bytes)
4. Payload data `[0 : UsedLen]`

Padding bytes in the payload block **must not** be included.

### 5.3 Error Handling

If the computed CRC does not match the transmitted value:
- the packet **must be discarded**,
- the implementation **must not crash or abort**,
- optional logging is permitted.

---

## 6. UsedLen Field

- Size: 2 bytes
- Type: unsigned 16-bit integer
- Byte order: network order (big-endian)

`UsedLen` defines the number of valid payload bytes.

Constraint:
```
0 <= UsedLen <= PayloadBlockSize
```

---

## 7. Payload Block Size

The physical payload block size is determined by:

1. `SizeId` lookup in the base table
2. optional doubling if `BigMode = 1`

### 7.1 Base Size Table (NORMAL mode)

| SizeId | PayloadBlockSize (bytes) |
|------:|-------------------------:|
| 0x0 | 0 |
| 0x1 | 16 |
| 0x2 | 32 |
| 0x3 | 64 |
| 0x4 | 96 |
| 0x5 | 128 |
| 0x6 | 192 |
| 0x7 | 256 |
| 0x8 | 384 |
| 0x9 | 512 |
| 0xA | 768 |
| 0xB | 1024 |
| 0xC | 1536 |
| 0xD | 2048 |
| 0xE | 3072 |
| 0xF | 4096 |

### 7.2 BIG Mode

If `BigMode = 1`, the payload block size is exactly doubled.

Maximum payload block size in BIG mode: **8192 bytes**.

---

## 8. Payload Rules

- Payload content is **opaque binary data**.
- The Core Frame does not interpret payload format.
- Text, structured data, compression, or encryption are handled by higher layers.

---

## 9. Acknowledgement Semantics

If `AckRequested = 1`, the receiver is requested to send an explicit acknowledgement.

The acknowledgement format and transport are defined outside the Core Frame and are handled by system-level conventions.

---

## 10. Compatibility and Forward Extension Rules

- Unknown flags **must be ignored**.
- Unknown SizeId values are invalid and must result in packet discard.
- Optional extensions may be added in future versions using the `HasExt` mechanism.

Implementations must remain compatible with older Core Frame versions unless explicitly stated otherwise.

---

## 11. Out of Scope

The following concerns are intentionally excluded from this specification:

- inter-link routing logic
- orchestrator discovery
- security, encryption, or authentication
- transport-specific framing
- payload semantics

These are handled by higher layers such as Routing, System, or Application specifications.

---

**End of TamTam Core Frame Specification v1.0**

