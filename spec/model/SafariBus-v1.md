# Safari Bus Transport Model v1

Status: Draft  
Scope: Normative specification  
Audience: Architects, protocol designers, backend implementers  
Non-Goals: Implementation details, APIs, wire formats

---

## 1. Overview

Safari Bus is a logical transport model used by **TamTam** for message delivery between nodes, services, and endpoints.

The model defines a **three-lane bus** optimized for different classes of traffic:

- **Fast Lane** – latency-critical control and signaling
- **Bulk Lane** – large, finite, reliable transfers
- **Stream Lane** – continuous or unbounded data flows

Safari Bus is **language-agnostic**, **transport-agnostic**, and **implementation-independent**.  
It specifies *behavior*, *routing rules*, and *lifecycle*, not code.

---

## 2. Core Principles

Safari Bus is governed by the following principles:

1. **Separation by intent, not size**  
   Routing decisions are based on semantic intent, not payload size alone.

2. **Fairness without starvation**  
   No lane may starve another indefinitely.

3. **Explicit lifecycle**  
   Every transmission has a defined beginning, progression, and termination.

4. **Backpressure awareness**  
   Congestion propagates upstream via defined signals.

5. **Transport neutrality**  
   The model may be mapped onto any physical or logical transport.

---

## 3. The Three Lanes

Safari Bus consists of three independent logical lanes.

### 3.1 Fast Lane

**Purpose:**  
Low-latency, small, time-sensitive messages.

**Characteristics:**

- Payloads are small and bounded
- Delivery is prioritized over throughput
- May be dropped or superseded if stale
- Typically synchronous or request-response

**Typical Uses:**

- Control messages
- Handshakes
- State changes
- Capability negotiation
- Heartbeats

**Constraints:**

- Must not be used for bulk data
- Must remain responsive under load
- Preempts other lanes when necessary

---

### 3.2 Bulk Lane

**Purpose:**  
Reliable transfer of finite, potentially large data sets.

**Characteristics:**

- Payload size may be large
- Delivery must be complete and ordered
- Retries and resumability are expected
- Throughput is favored over latency

**Typical Uses:**

- File transfer
- Database snapshots
- Artifact exchange
- Structured data batches

**Constraints:**

- Must yield to Fast Lane traffic
- May be throttled under congestion
- Completion is mandatory once accepted

---

### 3.3 Stream Lane

**Purpose:**  
Continuous or long-lived data flows.

**Characteristics:**

- Potentially unbounded duration
- Ordered delivery within a stream
- Backpressure is essential
- Partial loss may be acceptable depending on policy

**Typical Uses:**

- Media streams
- Live telemetry
- Event feeds
- Interactive data flows

**Constraints:**

- Must coexist fairly with Bulk Lane
- Must react to downstream pressure
- Termination must be explicit

---

## 4. Lane Selection Rules

A message **MUST** be assigned to exactly one lane.

### 4.1 Selection Criteria (Normative)

| Criterion                     | Preferred Lane |
|------------------------------|----------------|
| Latency critical             | Fast           |
| Finite + large               | Bulk           |
| Continuous / unbounded       | Stream         |
| Control or coordination      | Fast           |
| Data replication             | Bulk           |
| Live feed or session         | Stream         |

If ambiguity exists, **Fast Lane takes precedence**, followed by **Stream**, then **Bulk**.

---

## 5. Routing Model

### 5.1 Logical Routing

Routing is expressed in terms of **endpoints**, not physical connections.

A route consists of:

- Source
- Destination
- Lane
- Policy context

Routing decisions:

- MAY consider load
- MAY consider capability
- MUST respect lane semantics

---

### 5.2 Lane Isolation

Each lane is logically isolated:

- Congestion in Bulk MUST NOT block Fast
- Stream backpressure MUST NOT collapse Fast
- Fast MUST NOT permanently starve others

Isolation is behavioral, not necessarily physical.

---

## 6. Fairness and Scheduling

### 6.1 Scheduling Guarantees

Implementations MUST guarantee:

- Fast Lane bounded latency
- Bulk Lane eventual completion
- Stream Lane sustained progress

### 6.2 Starvation Prevention

No lane may be blocked indefinitely if:

- It complies with backpressure
- Resources eventually become available

Fairness MAY be implemented using:

- Weighted scheduling
- Time slicing
- Token or credit systems

The specific algorithm is out of scope.

---

## 7. Backpressure Model

Backpressure is a **first-class concept**.

### 7.1 Backpressure Signals

Backpressure MAY be expressed as:

- Explicit signals
- Window reduction
- Credit exhaustion
- Rate hints

### 7.2 Propagation Rules

- Stream Lane backpressure MUST propagate upstream
- Bulk Lane backpressure MAY pause acceptance
- Fast Lane SHOULD degrade gracefully, not stall

---

## 8. Lifecycle Model

Every Safari Bus transmission follows a lifecycle.

### 8.1 Common Phases

1. **Intent Declaration**  
   Sender declares lane and intent.

2. **Admission**  
   Receiver or intermediary accepts or rejects.

3. **Transfer**  
   Data moves according to lane semantics.

4. **Completion or Termination**  
   Explicit end state is reached.

---

### 8.2 Lane-Specific Lifecycle Notes

**Fast Lane:**

- May complete implicitly
- Stale messages MAY be dropped

**Bulk Lane:**

- Completion MUST be acknowledged
- Partial completion is invalid unless explicitly negotiated

**Stream Lane:**

- Begins with explicit open
- Ends with explicit close or abort
- May be suspended and resumed

---

## 9. Failure Semantics

Failures MUST be explicit.

Possible failure classes:

- Admission failure
- Mid-transfer interruption
- Policy violation
- Timeout

Each failure MUST resolve to one of:

- Retry allowed
- Resume allowed
- Abort required

Silent failure is forbidden.

---

## 10. Versioning and Evolution

Safari Bus is versioned as a **model**, not an API.

- Backward compatibility is preferred
- New lanes require a new major version
- Extensions MUST NOT redefine existing semantics

---

## 11. Non-Goals

Safari Bus explicitly does NOT define:

- Wire formats
- Serialization
- Encryption
- Authentication
- Transport protocols
- APIs or SDKs

These are layered concerns.

---

## 12. Summary

Safari Bus provides a **semantic transport model** built around three lanes:

- **Fast** for control
- **Bulk** for transfer
- **Stream** for flow

It is designed to be simple, fair, explicit, and extensible.

Implementation comes later.

---

End of SafariBus-v1
