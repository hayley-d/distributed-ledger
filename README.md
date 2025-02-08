<p><a target="_blank" href="https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

# OCaml Decentralized DAG-Based Blockchain
A high-performance, scalable distributed ledger utilizing a Directed Acyclic Graph (DAG) structure for transaction validation and consensus. It is implemented in **OCaml** and leverages the **Avalanche consensus protocol** to achieve high throughput, low latency, and security against Sybil attacks. The design focuses on decentralization, scalability, and resilience, making it a strong candidate for real-world applications.

## Features:
- **DAG-based Architecture:** Transactions form a DAG rather than a linear chain, improving concurrency and scalability.
- **Avalanche Consensus:** A robust, metastable consensus mechanism optimized for high throughput and transaction finality.
- **Sybil Attack Resistance:** Utilizes staking mechanisms and network sampling to mitigate Sybil attacks.
- **Asynchronous Transaction Processing:** Transactions are validated in parallel without a single leader bottleneck.
- **Efficient State Propagation:** Optimized gossip protocol for rapid transaction dissemination across the network.
- **Decentralization:** Every member of the blockchain structure is able to access the entire distributed database.
- **Distributed Consensus**: Implements a consensus algorithm to ensure that events are consistently applied across all nodes in a distributed environment.
- 
- **Scalable Architecture**: The system is designed to scale horizontally to handle high throughput and large datasets in a distributed environment.
### System Components:
### DAG-based Architecture:
- Transactions are stored in a DAG, where each transaction validates multiple past transactions.
- Avoids traditional bottlenecks seen in linear blockchain architectures.
- Ensures **high throughput** by allowing multiple transactions to be confirmed simultaneously.
### Consensus Mechanism:
Consensus is done using Avalanche consensus protocol, which is a high throughput, parallelizable protocol. The transitive voting optimizs transaction throughput and the subsampling ensures that the number of consensus messages a node sends during a query is always consistent regardless of sample size. This protocol also allows for configurable parameters improving overall system flexibility.

- Nodes repeatedly query a small, randomly selected subset of other nodes to determine transaction validity.
- Achieves consensus efficiently with low communication overhead.
- Provides strong probabilistic guarantees of finality after a small number of rounds.
The Avalanche consensus mechanism provides probabilistic finality with the following plugable parameters:

- k: Number of peers to query (default: 20)
- α: Quorum size (default: 15)
- β: Decision threshold (default: 15)
### Networking & Communication (gRPC-based P2P Layer)
- Nodes communicate using **gRPC**, ensuring efficient, high-speed message passing.
- Gossip protocol for rapid propagation of transactions and votes.


### **Transaction Model**
- Each transaction contains:
    - Unique identifier
    - Pointers to parent transactions
    - Digital signatures for authentication
    - Consensus metadata
- Transactions are considered finalized once they receive enough confidence from the network.
### **Security & Fault Tolerance**
- Byzantine fault-tolerant (BFT) properties ensure resilience to malicious nodes.
- Nodes are resistant to Sybil attacks via staking and probabilistic sampling.
## High-Level Flow
1. **Transaction Submission:** A user submits a transaction.
2. **Parent Selection:** The transaction references a small number of previous transactions in the DAG.
3. **Network Propagation:** The transaction is broadcasted to peers using a gossip protocol.
4. **Sampling & Querying:** Validators repeatedly query random node subsets to determine the transaction’s validity.
5. **Consensus Formation:** Once a transaction accumulates enough confidence, it is considered finalized.
6. **Ledger Update:** The finalized transaction is permanently added to the DAG.
7. **Global State Synchronization:** Nodes maintain a consistent view of the DAG through periodic synchronization.
## Performance & Scalability Considerations
- **Horizontal Scaling:** More nodes improve network security and validation speed.
- **Low Latency Consensus:** Avalanche achieves sub-second finality for most transactions.
- **Reduced Overhead:** Efficient querying reduces the cost of network communication.




<!--- Eraser file: https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q --->
