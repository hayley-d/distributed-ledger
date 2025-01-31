<p><a target="_blank" href="https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

# OCaml Distributed Ledger with DAG Architecture
A high-performance, scalable distributed ledger implementation using Directed Acyclic Graph (DAG) architecture with Avalanche consensus protocol, written in OCaml. This project demonstrates advanced distributed systems concepts while achieving higher throughput and lower latency compared to traditional blockchain designs.

## Features:
- **DAG-based Architecture:** Parallel transaction processing through DAG structure
- **Avalanche Consensus Mechanism: **
- **Cryptography:** Blockchain transactions are verified and trustworthy because of complex computations and cryptographic proof between the parties.
- **Immutability:** Records in a blockchain can’t be modified or deleted.
- **Provenance:** It’s possible to trace the origin of each transaction in the blockchain ledger.
- **Decentralization:** Every member of the blockchain structure is able to access the entire distributed database.
- **Distributed Consensus**: Implements a consensus algorithm to ensure that events are consistently applied across all nodes in a distributed environment.
- **Fault Tolerance**: Designed to handle node failures gracefully, with mechanisms for recovering and maintaining consistency without losing data.
- **Scalable Architecture**: The system is designed to scale horizontally to handle high throughput and large datasets in a distributed environment.
### System Components:
### DAG-based Architecture:
There are a number of advantages to a DAG-based blockchain as compared to a linear chain.

- Parallel transaction processing through DAG structure
- some more reasons I can't think of.....
### Consensus Mechanism:
Consensus is done using Avalanche consensus protocol, which is a high throughput, parallelizable protocol. The transitive voting optimizs transaction throughput and the subsampling ensures that the number of consensus messages a node sends during a query is always consistent regardless of sample size. This protocol also allows for configurable parameters improving overall system flexibility.

The Avalanche consensus mechanism provides probabilistic finality with the following plugable parameters:

- k: Number of peers to query (default: 20)
- α: Quorum size (default: 15)
- β: Decision threshold (default: 15)
### 





<!--- Eraser file: https://app.eraser.io/workspace/D2SvVYOv2VemDF6vPB5Q --->