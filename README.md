<p><a target="_blank" href="https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

# Distributed Ledger with Event Sourcing
The Distributed Ledger is designed to implement an event-driven system that guarantees data integrity, high availability, and fault tolerance using a distributed ledger and event sourcing techniques. The system allows for the immutability of events and ensures that any state change within the system can be tracked through event logs. Implements a decentralized private blockchain distributed ledger.

The system can be used in applications requiring strong consistency and reliability, such as banking, auditing, and supply chain management. The project leverages **distributed systems principles**, **event sourcing**, and **functional programming** (OCaml) to create a robust and scalable solution.



## Features:
- **Cryptography: **Blockchain transactions are verified and trustworthy because of complex computations and cryptographic proof between the parties.
- **Immutability: **Records in a blockchain can’t be modified or deleted.
- **Provenance: **It’s possible to trace the origin of each transaction in the blockchain ledger.
- **Decentralization: ** Every member of the blockchain structure is able to access the entire distributed database.
- **Distributed Consensus**: Implements a consensus algorithm to ensure that events are consistently applied across all nodes in a distributed environment.
- **Fault Tolerance**: Designed to handle node failures gracefully, with mechanisms for recovering and maintaining consistency without losing data.
- **Scalable Architecture**: The system is designed to scale horizontally to handle high throughput and large datasets in a distributed environment.


### System Components:
1. **Core Ledger Service (OCaml):**
    - **Purpose**: This is the heart of the system, where transactions are recorded and validated.
    - **Responsibilities**:
        - Store blocks of transactions.
        - Maintain a consistent and immutable ledger.
        - Apply consensus rules to validate transactions.
        - Handle the addition of new blocks.
    - **Why OCaml?**: OCaml’s strong functional paradigm and immutability make it perfect for a blockchain-style system where consistency and immutability are crucial.
2. **Consensus Mechanism (PBFT):**
    - **Purpose**: Nodes communicate with each other to reach consensus, even if some nodes act maliciously or fail (Byzantine faults). A leader node proposes a block, and other nodes validate and agree on it.
    - **Responsibilities**:
        - Implement a consensus algorithm.
        - Communicate between nodes to ensure no conflicting transactions.
    - **Why PBFT?**: High throughput and low latency
**Node Communication (gRPC):**

- **Purpose**: Enable communication between nodes in the distributed ledger network.
- **Responsibilities**:
    - Establish secure communication channels between distributed nodes.
    - Enable transaction propagation and block validation across nodes.
- **Why gRPC?**: gRPC provides high-performance communication for microservices, and its support for streaming is a good fit for handling real-time updates in a distributed system.


### **High-Level Flow**:
1. **Client Request**: A user submits a transaction request.
2. **Rate Limiter**: The request is checked against rate limits.
3. **Load Balancer**: The request is routed to an available validation service.
4. **Transaction Validation**: The transaction is validated using business rules and transaction logic.
5. **Consensus**: The validated transaction is sent to consensus (PBFT) to ensure agreement across the network.
6. **Ledger Update**: Once validated, the transaction is added to a new block in the ledger.
7. **Block Storage**: The new block is stored in RocksDB.
8. **Block Propagation**: The block is propagated to all other nodes using gRPC.
9. **Node Synchronization**: Other nodes receive the new block and add it to their local ledger.




<!--- Eraser file: https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q --->