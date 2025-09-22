# Project 2: Gossip Protocol

## Team Members

- Chinmai Mandala 

## What is Working

- Implemented **Gossip Algorithm** and **Push-Sum Algorithm** using the actor model in Gleam.
- Supported topologies:
  - Full Network
  - 3D Grid
  - Line
  - Imperfect 3D Grid
- Measures convergence time using Erlang system time with millisecond precision.
- Generates convergence plots for both Gossip and Push-Sum algorithms.

## Largest Network Size Tested

- Full: 100 nodes
- 3D Grid: 100 nodes
- Line: 100 nodes
- Imperfect 3D: 100 nodes

## Instructions to Run

Compile and run the project using:

```
gleam build
gleam run -- <numNodes> <topology> <algorithm>
```

Example:

```
gleam run -- 50 full gossip
```

- `<numNodes>`: Number of nodes in the network (integer).
- `<topology>`: One of `full`, `3D`, `line`, `imp3D`.
- `<algorithm>`: One of `gossip`, `push-sum`.

## Results Summary

- Gossip converges faster than Push-Sum across all topologies.
- Full topology achieves the fastest convergence.
- Line topology is consistently the slowest due to limited neighbor connectivity.
- Imperfect 3D offers performance between 3D and Full topologies, showing that adding random links improves convergence.

Refer to `project2.pdf` for detailed plots and experimental analysis.
