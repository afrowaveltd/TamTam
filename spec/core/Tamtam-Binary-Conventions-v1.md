# TamTam Binary Conventions (v1)

## 1. Purpose
This document defines **binary-level conventions** used by the TamTam protocol.
Its goal is to ensure that all implementations (C, Assembly, C#, and others)
produce **identical byte layouts** and can interoperate without ambiguity.

This document is **normative**.

---

## 2. Fundamental Principles

1. TamTam is a **byte-oriented protocol**.
2. All protocol structures have a **fixed, deterministic layout**.
3. No implicit padding, alignment, or language-specific layout rules are allowed.
4. All numeric fields have explicitly defined size and byte order.

---

## 3. Byte Order (Endianness)

- **Little-endian** is used for all multi-byte numeric fields.
- Rationale:
  - Matches common CPU architectures (x86, ARM default LE)
  - Simplifies Assembly inspection and debugging

### Examples

| Value | Size | Bytes (hex) |
|------|------|-------------|
| 0x01 | u16  | 01 00 |
| 0x1234 | u16 | 34 12 |
| 0x12345678 | u32 | 78 56 34 12 |

---

## 4. Integer Types

All integer types are **unsigned** unless explicitly stated otherwise.

| Type | Size | Description |
|----|----|------------|
| u8  | 1 byte | Unsigned 8-bit integer |
| u16 | 2 bytes | Unsigned 16-bit integer |
| u32 | 4 bytes | Unsigned 32-bit integer |
| u64 | 8 bytes | Unsigned 64-bit integer |

Signed integers are not used in the TamTam core protocol.

---

## 5. Boolean Values

- Boolean values are encoded as **u8**.
- Valid values:
  - `0x00` = false
  - `0x01` = true
- All other values are **invalid**.

---

## 6. Character Encoding

- All textual payloads use **UTF-8** encoding.
- No BOM is allowed.
- Strings inside binary structures are:
  - either fixed-length UTF-8 byte arrays
  - or length-prefixed (explicit length field)

The TamTam core does not define implicit null-terminated strings.

---

## 7. Alignment and Padding

- **No automatic padding** is permitted.
- All fields are packed sequentially.
- Field offsets are defined explicitly by the specification.

Implementations in C **must** use packed structures or manual serialization.

---

## 8. Versioning Rule

- Binary structures are versioned explicitly via a **Version field**.
- New protocol versions:
  - must never reinterpret existing fields
  - may append new fields at the end

Backward compatibility is mandatory within the same major version.

---

## 9. Checksums and Integrity (Placeholder)

- This version does **not** mandate a specific checksum or CRC.
- Fields for integrity validation may exist in headers but are optional.
- Future versions may standardize CRC32 or similar mechanisms.

Implementations must ignore checksum fields they do not understand.

---

## 10. Assembly-Level Expectations

All TamTam binary layouts must be inspectable using simple Assembly tools:
- byte-by-byte dumps
- fixed offsets
- deterministic interpretation

A valid TamTam frame must be understandable using only:
- a hex dump
- this document
- the corresponding header specification

---

## 11. Compliance

An implementation is **TamTam v1 compliant** if:
- it follows all rules defined in this document
- it produces identical byte streams for identical inputs
- it can parse compliant frames from other implementations

---

End of document.

