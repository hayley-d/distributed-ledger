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


## System 
### Transaction Service
- Function: Responsible for accepting, validating and processing transactions.
- **Responsibilities**:
    - **Transaction Validation**: Check that the transaction follows the system’s rules.
    - **Transaction Pool**: Queue incoming transactions for future processing.
    - **Transaction Confirmation**: When validated, confirm the transaction and propagate it to other nodes.
- **Interactions**: Communicates with Validation Service and Blockchain Service.
- **Technology**: gRPC for inter-service communication.
### Blockchain Service (Ledger store)
**Function**: Manages the ledger’s state.

**Responsibilities**:

- **Blockchain Creation and Validation**: Create blocks that contain transactions and ensure they adhere to the consensus protocol.
- **State Storage**: Store the ledger’s current state.
- **Block Validation and Linking**: Ensure blocks are valid (cryptographic hashes, links between blocks) (**Merkle Trees** and **SHA256** for cryptographic validation).
- **Storage**: Utilize a key-value store (S3) for persistent storage.
**Technology**: AWS S3 for local ledger storage.

**Interactions**: Communicates with **Transaction Service** and **Consensus Service**.

### Consensus Service
**Function**: Facilitates the consensus algorithm to ensure all nodes agree on the ledger’s state.

**Responsibilities**:

- **Consensus Algorithm**: Implement the consensus mechanism ( **Proof of Work (PoW)**, **Proof of Stake (PoS)**, **PBFT**, or **Raft**).
- **Leader Election**: If using leader-based consensus (e.g., **PBFT**, **Raft**), the consensus service handles leader election.
- **Transaction Confirmation**: Once the consensus is reached, confirm and commit the transactions to the blockchain.
**Technology**: Custom algorithm or existing libraries like **Raft** or **PBFT**.

**Interactions**: Communicates with **Transaction Service**, **Blockchain Service**, and **Node Communication Service**.

### Node Communication Service
- **Function**: Manages the communication between nodes in the system. This is essentially the peer-to-peer (P2P) layer.
- **Responsibilities**:
    - **Node Discovery**: Discover and connect to other peers in the network.
    - **Data Propagation**: Propagate transactions and blocks between nodes.
    - **Message Synchronization**: Ensure that once a transaction is confirmed, it is sent to all other nodes.
    - **Heartbeat / Health Checks**: Ensure the health of peers and handle node failure detection.
- **Technology**: **gRPC**, **WebSockets**, or **Libp2p** (for decentralized P2P networking).
- **Interactions**: Communicates with **Transaction Service**, **Blockchain Service**, and **Consensus Service**.
1. **Cryptography Service**
    - **Function**: Provides cryptographic functionalities like hashing, digital signatures, and encryption to ensure data integrity and security.
    - **Responsibilities**:
        - **Digital Signature Verification**: Ensure that the sender of a transaction is authorized to perform the action (e.g., using **ECDSA** or **RSA**).
        - **Hashing**: Create hashes for transactions and blocks using **SHA256** or other hashing algorithms.
        - **Encryption**: Encrypt sensitive data before storing or transmitting it.
    - **Technology**: Use libraries like **Crypto++**, **OpenSSL**, or **libsodium**.
    - **Interactions**: Communicates with **Transaction Service**, **Blockchain Service**, and **Consensus Service** for signing, hashing, and encryption tasks.
2. **Smart Contract Service (Optional)**
    - **Function**: Provides the execution and management of smart contracts on the ledger, allowing users to write decentralized applications (DApps).
    - **Responsibilities**:
        - **Contract Execution**: Executes smart contracts upon transaction execution.
        - **Contract State**: Tracks the state of deployed contracts.
        - **Event Handling**: Listens for events triggered by contracts.
    - **Technology**: Can use **Ethereum’s Solidity** or **Rust** for contract execution and smart contract virtual machines.
    - **Interactions**: Communicates with **Blockchain Service** and **Transaction Service** to trigger transactions based on contract logic.
3. **Transaction History Service (Optional)**
    - **Function**: Provides an interface to retrieve the transaction history from the ledger.
    - **Responsibilities**:
        - **Transaction Indexing**: Index and retrieve transactions by timestamp, sender, receiver, or other metadata.
        - **Audit and Analytics**: Support querying for transaction data for auditing or analytics.
    - **Technology**: **Elasticsearch** or **SQL/NoSQL database** for indexing and querying.
    - **Interactions**: Communicates with **Blockchain Service** for fetching transaction data.
4. **API Gateway (External Interface)**
    - **Function**: Provides external access to the distributed ledger system, enabling interaction from external clients.
    - **Responsibilities**:
        - **API Management**: Expose RESTful APIs or GraphQL APIs to interact with the ledger.
        - **Transaction Submission**: Allow users to submit transactions to the ledger.
        - **Query Access**: Provide endpoints for users to query the ledger state or transaction history.
    - **Technology**: **Express** (Node.js), **FastAPI** (Python), or **Gin** (Go) for creating REST APIs.
    - **Interactions**: Communicates with **Transaction Service** and **Blockchain Service**.




### System Components and Their Languages:
1. **Core Ledger Service (OCaml):**
    - **Purpose**: This is the heart of the system, where transactions are recorded and validated.
    - **Responsibilities**:
        - Store blocks of transactions.
        - Maintain a consistent and immutable ledger.
        - Apply consensus rules to validate transactions.
        - Handle the addition of new blocks.
    - **Why OCaml?**: OCaml’s strong functional paradigm and immutability make it perfect for a blockchain-style system where consistency and immutability are crucial.
2. **Consensus Mechanism (OCaml):**
    - **Purpose**: Ensure that all nodes agree on the state of the ledger.
    - **Responsibilities**:
        - Implement a consensus algorithm like Proof of Work or Raft to ensure the integrity and agreement across the distributed system.
        - Communicate between nodes to ensure no conflicting transactions.
    - **Why OCaml?**: OCaml’s functional nature allows for clear and concise implementation of complex algorithms like consensus, as well as handling state transitions in a predictable way.
3. **Smart Contracts (OCaml or JavaScript/TypeScript):**
    - **Purpose**: Handle automation and execution of predefined contracts.
    - **Responsibilities**:
        - Define the rules for contract execution.
        - Verify and execute transactions based on contract conditions.
        - Integrate with the ledger to modify state based on contract outputs.
    - **Why OCaml/JavaScript?**: While OCaml could handle the logic for smart contracts, you might use JavaScript for interaction with web interfaces or external systems due to its prevalence in web applications and blockchain ecosystems.
4. **Node Communication (gRPC or HTTP in OCaml or Rust):**
    - **Purpose**: Enable communication between nodes in the distributed ledger network.
    - **Responsibilities**:
        - Establish secure communication channels between distributed nodes.
        - Enable transaction propagation and block validation across nodes.
    - **Why gRPC?**: gRPC provides high-performance communication for microservices, and its support for streaming is a good fit for handling real-time updates in a distributed system.
5. **Client Interface (React/Frontend with OCaml bindings or JavaScript):**
    - **Purpose**: Provide a user-friendly interface to interact with the ledger and smart contracts.
    - **Responsibilities**:
        - Enable users to submit transactions.
        - Display transaction statuses and ledger states.
    - **Why React?**: It is a common frontend framework, and you can use OCaml's BuckleScript to create bindings to interact with it if you want to stick to the functional language stack.
6. **Data Storage/Blockchain (OCaml or IPFS):**
    - **Purpose**: Store transaction data and ensure the immutability of records.
    - **Responsibilities**:
        - Persist the blockchain data.
        - Use techniques like Merkle Trees for efficient hashing and validation.
    - **Why OCaml or IPFS?**: OCaml’s performance can help manage data storage, while IPFS can be integrated as a decentralized file storage solution.


**Transaction** → **Load Balancer** → **Rate Limiter** → **Transaction Validation** (OCaml)

**Validated Transaction** → **Ledger Service** (OCaml) → **Block Created**

**Consensus Algorithm** → **Block Propagation to All Nodes**



# Key characteristics of the blockchain architecture
- 




<!--- Eraser file: https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q --->