# TamTam – Routing & Dispatcher Specification v1.0

## 1. Scope

This document defines the **Routing and Dispatcher layer** of the TamTam system.

It specifies:
- how multiple TamTam links are interconnected,
- how packets are routed between links,
- the role of the orchestrator, dispatcher, and gateway,
- roaming packet handling rules.

This specification builds on, but does not modify, the TamTam Core Frame.

---

## 2. Terminology

### Link
A **link** is a local TamTam communication domain.

- All nodes on a link share the same ChannelId namespace.
- Packets within a link are delivered without inter-link routing.
- Each link has exactly one orchestrator.

### Orchestrator
An **orchestrator** is the authoritative control point of a link.

It:
- receives all packets entering or leaving the link,
- decides whether a packet is local or roaming,
- applies routing policy,
- interfaces with other orchestrators.

### Dispatcher
The **dispatcher** is the routing engine of an orchestrator.

It:
- examines packet headers and optional extensions,
- performs routing table lookups,
- forwards packets to the appropriate link or gateway.

The dispatcher never interprets payload data.

### Gateway
A **gateway** is a dispatcher component responsible for:
- adding or removing roaming extensions,
- transferring packets between links.

---

## 3. Design Principles

Routing in TamTam follows strict principles:

- Routing operates only on headers and extensions.
- Payload data is opaque and must never be inspected.
- Local traffic is never penalized for global routing.
- All routing decisions are explicit and deterministic.

---

## 4. Local vs Roaming Packets

### Local Packet
A packet is **local** if:
- the `HasExt` flag is `0`.

Local packets:
- remain within their originating link,
- are routed solely by ChannelId.

### Roaming Packet
A packet is **roaming** if:
- the `HasExt` flag is `1`, and
- a `DestOrchestratorId` is present.

Roaming packets:
- may leave their originating link,
- are routed toward the specified destination orchestrator.

---

## 5. Roaming Extension Handling

### Adding the Extension

When a packet must leave its local link:

1. The gateway sets `HasExt = 1`.
2. The gateway inserts `DestOrchestratorId`.
3. Integrity is recomputed.

### Removing the Extension

When a roaming packet reaches its destination link:

1. The gateway validates `DestOrchestratorId`.
2. The extension is removed.
3. The packet becomes local again.

The inner Core Frame remains unchanged.

---

## 6. Routing Table Model

Routing decisions are based on a routing table similar in concept to traditional network routing.

Each entry may contain:

- Destination OrchestratorId (or range)
- Next Hop Link
- Policy Flags
- Priority

The most specific matching rule must be applied.

---

## 7. Ring Forwarding (Backbone Mode)

TamTam supports a **ring-based backbone topology**.

In this model:
- orchestrators are connected in a logical ring,
- roaming packets circulate until a destination match is found.

### Forwarding Rules

- If destination matches local orchestrator → deliver.
- If not → forward to next orchestrator on the ring.

To prevent infinite loops:
- a hop counter or TTL mechanism must be applied.

---

## 8. Failure Handling

If routing fails:
- the packet must not be silently dropped,
- an explicit error or rejection may be generated on a system channel.

Partial delivery states must not exist.

---

## 9. Security Considerations

Routing layer security is intentionally minimal.

- Authentication and authorization are handled by higher layers.
- The routing layer assumes trusted orchestrator relationships.

Future profiles may extend this model.

---

## 10. Out of Scope

This specification does not define:

- orchestrator discovery mechanisms,
- encryption or authentication,
- dynamic routing protocols,
- payload-aware routing.

---

**End of TamTam Routing & Dispatcher Specification v1.0**

