# TamTam Addressing (v1)

## 1. Purpose
This document defines **how TamTam packets address their destination**.

TamTam supports two complementary addressing modes:
- **Entity addressing** (by `RecipientId`) for direct station/user/group communication and control replies.
- **Service addressing** (by `RecipientPort`) for service discovery, load balancing, and “anycast” style delivery.

The goal is to keep the data plane small and fast, while allowing richer control-plane behaviors.

---

## 2. Terms

- **Entity**: a specific target identity (Station/User/Group).
- **Service**: a capability exposed on one or more nodes (e.g., Translate, Trace, Ping).
- **Control plane**: packets that manage routing, discovery, policies, tracing, etc.
- **Data plane**: ordinary payload packets using established routes.

---

## 3. Addressing Fields (Header)
TamTam headers (v1) carry both fields:

- `RecipientKind` (enum): describes what kind of recipient is intended.
- `RecipientId` (u64): identity of the target entity (Station/User/Group).
- `RecipientPort` (u16): service port (logical service identifier).

**Key rule**: Which field is primary depends on `RecipientKind`.

---

## 4. Addressing Modes

### 4.1 Entity Addressing (Direct)
Use when you want a **specific** recipient.

**Rule**:
- `RecipientKind` = `Station` or `User` or `Group`
- `RecipientId` = target identity (non-zero)
- `RecipientPort` = `0` (default inbox) unless using a sub-service on that entity

**Typical uses**:
- direct messages (A → B)
- acknowledgements/retries and other return-to-sender control flows
- “dispatcher/coordinator control” addressed to a specific control entity

### 4.2 Service Addressing (Anycast / Many Providers)
Use when you want **a service**, not a particular machine.

**Rule**:
- `RecipientKind` = `Service`
- `RecipientPort` = service identifier (non-zero)
- `RecipientId` = `0` (or optional service-instance hint)

**Typical uses**:
- translation service (many servers can provide the same port)
- trace report service
- discovery services
- load balancing and “first available” behavior

### 4.3 Entity + Port (Bound Service on a Specific Entity)
Optional advanced pattern:

**Rule**:
- `RecipientKind` = `Station` (or `User` / `Group` in higher layers)
- `RecipientId` = target identity
- `RecipientPort` = sub-service port on that specific entity

**Typical uses**:
- “call service X on station B”
- pinned workflows and deterministic routing

---

## 5. Return-to-Sender and Control Replies
TamTam reliability/control relies on immutable sender identity.

**Rule**:
- Replies like `ACK`, `BUSY`, `RETRY` requests, and other control responses should be addressed using **Entity Addressing** back to the original sender.

In practice:
- outgoing packet carries `SenderId`
- the reply sets `RecipientKind = Station` (or relevant entity kind)
- `RecipientId = SenderId` of the original packet
- `RecipientPort = 0` (unless a dedicated control inbox port is adopted later)

This matches the principle:
- **Ports are for services. IDs are for internal/direct communication.**

---

## 6. Dispatcher/Coordinator Control
Control messages intended for a specific dispatcher/coordinator entity should be addressed by **RecipientId**.

Services provided by dispatchers/coordinators can still be exposed via `RecipientPort` using `RecipientKind=Service`, but direct operational control (e.g., “apply policy”, “open VPORT”, “route advise”) is best expressed as control-plane services.

Recommended pattern:
- Use `RecipientKind=Service` for **control-plane service endpoints** (e.g., `PORT_MGMT`, `ROUTE_POLICY`, `TRACE_REPORT`).
- Use `RecipientKind=Station` + `RecipientId` for **direct replies and targeted operations**.

---

## 7. Discovery and Route Rules
Discovery is a **control-plane operation**.

**Rule**:
- Packets do not “find a path” on every send.
- A path/rule is discovered once (or refreshed), cached, and then used for fast forwarding.

Discovery may be implemented by control packets such as:
- `DISCOVER_ID` / `DISCOVER_SERVICE`
- `ROUTE_QUERY` / `ROUTE_ADVISE`

These packets manage routing tables and policies in dispatchers/coordinators.

---

## 8. Examples

### 8.1 Direct message to a station
- `RecipientKind = Station`
- `RecipientId = <StationId_B>`
- `RecipientPort = 0`

### 8.2 Send to translation service (any provider)
- `RecipientKind = Service`
- `RecipientPort = 0x00A1` (example)
- `RecipientId = 0`

### 8.3 ACK reply to sender
- `RecipientKind = Station`
- `RecipientId = <SenderId_from_original_packet>`
- `RecipientPort = 0`

---

## 9. Notes and Future Extensions
- A future smart-header extension may add a `SessionId` / `PortNamespace` for large-scale ephemeral routing labels.
- Higher layers may map GUIDs to `u64` IDs; the on-wire core remains compact.

---

End of document.

