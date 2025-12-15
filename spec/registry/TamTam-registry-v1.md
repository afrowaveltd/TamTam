# TamTam – Registries Specification v1.0

This document defines the **formal registries** used by the TamTam Core and Routing specifications.

Registries provide a stable, authoritative reference for values that must remain consistent across implementations.

---

## 1. Scope

This registry specification covers:
- SizeId registry
- Flag registry
- Channel registry conventions
- Reserved ranges and extension rules

The registries defined here are normative.

---

## 2. SizeId Registry

The SizeId registry defines the mapping between `SizeId` values and payload block sizes.

### 2.1 SizeId Table (NORMAL mode)

| SizeId | Payload Block Size (bytes) | Status |
|------:|---------------------------:|--------|
| 0x0 | 0 | Defined |
| 0x1 | 16 | Defined |
| 0x2 | 32 | Defined |
| 0x3 | 64 | Defined |
| 0x4 | 96 | Defined |
| 0x5 | 128 | Defined |
| 0x6 | 192 | Defined |
| 0x7 | 256 | Defined |
| 0x8 | 384 | Defined |
| 0x9 | 512 | Defined |
| 0xA | 768 | Defined |
| 0xB | 1024 | Defined |
| 0xC | 1536 | Defined |
| 0xD | 2048 | Defined |
| 0xE | 3072 | Defined |
| 0xF | 4096 | Defined |

### 2.2 BIG Mode

If the `BigMode` flag is set, the payload block size is doubled.

Maximum payload block size in BIG mode: **8192 bytes**.

---

## 3. Flag Registry (Byte1 Low Nibble)

The following flags are defined in the low nibble of Header Byte1.

| Bit | Name | Meaning | Priority |
|----:|------|--------|----------|
| 0 | BigMode | Double payload block size | P0 |
| 1 | AckRequested | Explicit acknowledgement requested | P1 |
| 2 | Priority | High-priority scheduling hint | P1 |
| 3 | HasExt | Optional header extension present | P0 |

### 3.1 Flag Handling Rules

- Unknown flags **must be ignored**.
- Flags may be advertised via capability handshake.
- Flags must not alter payload semantics.

---

## 4. ChannelId Registry (Conventions)

ChannelId is an 8-bit value with **local scope** within a link.

The following ranges are recommended:

| Range | Purpose |
|------:|--------|
| 0–15 | System and control channels |
| 16–63 | Core services |
| 64–127 | Application channels |
| 128–255 | Experimental / private |

ChannelId assignments are link-local and must not be interpreted globally.

---

## 5. DestOrchestratorId Registry

`DestOrchestratorId` is a 16-bit identifier used exclusively by the routing layer.

### Rules

- Value `0x0000` is reserved and must not be used for routing.
- Valid orchestrator identifiers are assigned by deployment.
- The registry is external to TamTam Core and may be environment-specific.

---

## 6. Reserved Values and Extension Rules

### 6.1 Reserved SizeId

All SizeId values are currently defined.

Future revisions may:
- redefine sizes only in new major versions,
- introduce alternative size tables via capability profiles.

### 6.2 Reserved Flags

All low-nibble flag bits are currently assigned.

Future extensions may:
- introduce higher-level profiles,
- add additional header extensions beyond roaming.

---

## 7. Forward Compatibility Rules

- Implementations must accept packets with unknown flags.
- Packets with invalid SizeId values must be discarded.
- Extensions must never invalidate existing Core Frame rules.

---

**End of TamTam Registries Specification v1.0**

