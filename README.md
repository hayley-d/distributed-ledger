<p><a target="_blank" href="https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

# Distributed Ledger with Event Sourcing
The Distributed Ledger is designed to implement an event-driven system that guarantees data integrity, high availability, and fault tolerance using a distributed ledger and event sourcing techniques. The system allows for the immutability of events and ensures that any state change within the system can be tracked through event logs. 

The system can be used in applications requiring strong consistency and reliability, such as banking, auditing, and supply chain management. The project leverages **distributed systems principles**, **event sourcing**, and **functional programming** (OCaml) to create a robust and scalable solution.



## Features:
- **Immutability of Data**: Ensures that events cannot be modified, providing an audit trail for every action performed on the system.
- **Event Replay**: The system can reconstruct the state of any system component by replaying the recorded events, making it fault-tolerant and ensuring eventual consistency.
- **Distributed Consensus**: Implements a consensus algorithm (e.g., Raft or Paxos) to ensure that events are consistently applied across all nodes in a distributed environment.
- **Fault Tolerance**: Designed to handle node failures gracefully, with mechanisms for recovering and maintaining consistency without losing data.
- **Scalable Architecture**: The system is designed to scale horizontally to handle high throughput and large datasets in a distributed environment.
## Technologies:
- **OCaml**: Functional programming language chosen for its immutability support and strong type system.
- **Paxos**: Consensus algorithms for ensuring consistency in the distributed environment.
- **gRPC**: For communication between services, offering high-performance and low-latency messaging.
- **Docker**: To containerize the system and deploy it across multiple instances.
- **Kafka**: For managing event streams and ensuring durability
## Implementation Overview 
### 1. System Design:  
- **Event Store: **The event store stores all events in a durable and immutable manner. Each event is a record of a system change. This store is the heart of the system, and its integrity is paramount. Events are indexed by their timestamps to allow quick lookups.  
- **Event Processor: **The event processor listens to new events and applies them to the current state of the system. It is stateless, meaning it can be horizontally scaled, and it can replay events to rebuild the system state from scratch if necessary.**  **
- **Consensus Layer (Raft): **This component ensures that all nodes in the system have a consistent view of the events. When an event is submitted, the consensus algorithm ensures that the event is applied consistently across all nodes, and that any node can join or leave the system without compromising the state.  
- **API Layer:** The API allows external systems to submit events and query the current state of the system. It exposes endpoints for submitting events, querying the ledger, and fetching system health metrics.
### 2. Event Sourcing:  
- Each event represents a **discrete change in the system**.  
- Events are **stored sequentially**, and the system can replay events to reconstruct the current state at any point in time.  
- This makes the system **highly flexible and fault-tolerant**, as it can rebuild the system state from the event logs if necessary. 
### 3. Fault Tolerance & Recovery:  
- The system is designed to be resilient to node failures. If a node crashes, it can recover by replaying the events from the event store.   
- The consensus layer ensures that nodes remain consistent even in the presence of network partitions or failures. 
### 4. Scaling:  
- The system is designed to **scale horizontally** by adding more event processors and consensus nodes. This allows it to handle an increasing volume of events as needed. 
### 5. Security:  
- The system can **incorporate cryptographic signing of events** to ensure that events cannot be tampered with. This is particularly useful for audit trails and ensuring the integrity of financial systems. 






<!--- Eraser file: https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q --->