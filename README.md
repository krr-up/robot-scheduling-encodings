# robot-scheduling-encodings
Encodings for the robot-scheduling paper

## Formalisation

- The Juggling robots problem consists of:
  - a set of pickup and putdown tasks
  - a set of robots
  - an assignment of robots to tasks in some order
  - a directed graph of nodes
  - a route through the graph and conflict free schedule that satisfies the
    assigned tasks in the correct order

## Fact Format

The fact format for the encoding (which should remain consistent with the format used for the paper).

| Fact Format (Graph and Tasks)   | Description                                                  |
|---------------------------------|--------------------------------------------------------------|
| `edge(V,V',Weight)`             | Warehouse graph (unidirected) edges between vertices         |
| `robot(R)`                      | R is a robot                                                 |
| `home(R,V)`                     | The docking home for R - always plan to return here          |
| `start(R,V)`                    | The start location for R - different to home for replanning  |
| `conflict(v,V,V')`              | Vertex conflict between V and V'                             |
| `conflict(e,(V1,V1'),(V2,V2'))` | Edge conflict between (V1,V1') and (V2,V2')                  |
|                                 |                                                              |
| `task(T,V)`                     | Task T has an action to be executed at V (eg. pickup action) |
| `depends(wait,T,T')`            | Action for T' cannot be executed until T has been executed   |
| `depends(deliver,T,T')`         | T is a pickup action and T' the corresponding putdown action |


## Directory Structure

A rough starting structure:

| File/Directory    | Description                                    |
|-------------------|------------------------------------------------|
| `sourceme.sh`     | Setup the paths for the scripts                |
| `encodings/`      | Directory for different encodings              |
| `instances/`      | Some randomly generated problem instances      |
| `tests/`          | Tests for debugging the encodings              |
| `scripts/`        | Bash scripts                                   |



## Installation

### General

`clingo` and `clingo-dl` need to be installed:

    conda install -c potassco clingo clingo-dl


### Encoding testing

For testing the encoding install `networkx` and`clorm`:

    conda install networkx
    conda install -c potassco clorm


## Running

### Computing Shortest Paths

- There are a number of different solving options. But the high-performance
  options rely on pre-computed shortest path information.
- The rationale is that the shortest path data needs to be computed only once
  for any given graph, so in any given warehouse it would be possible to
  pre-compute the shortest paths and then reuse for any combination of tasks.
- To generate a shortest path instance:

  `shortest_path.py <input-instance> > <output-instance>`

- For example:

  `shortest_path.py tests/instances/instance1.lp > tmp.lp`

- The directory `instances/basic` contains randomly generated instances without
  shortest-path data and the matching shortest path versions in `instances/sp`.

### Walk Encoding

- The walk encoding closely follows the formalisation
- You need to specify a maximum horizon

  `solve_walk.sh -m <max_horizon> <instance-name>`

For example:

  `cd tests/instances ; solve_walk.sh -m 20 instance1.lp -r`

- For options:

  `solve_walk.sh -h`



## Path Encodings

- Path encodings divide each robot's route into a sequence of acyclic paths,
  where a path is (roughly) associated with a task.
- Since a path is acyclic there are problem instances that the path encodings
  cannot solve (even though there are satisfiable). But the benefit is much
  faster solving times.
- Path encodings don't need a horizon.
- Two path encodings: one where we track both the arrival and exit times of a
  robot at a node, and one where we only track the arrival times.
- Within the two path encodings we consider a number of variants. Some variants
  rely on pre-computed shortest path information.

### Full Path Encoding

- Tracks both the arrival and exit times of a robot at a node.

  `solve_full.sh <instance-name>`

- For options:

  `solve_full.sh -h`

- In particular to run a high-performance variant:

  `solve_full.sh -v t1_corr2_lb2_mh1 instances/sp/20x4_15_1_75_100_2_6_3_replenish_many_edges.lp`


### Fast Path Encoding

- Tracks only the arrival times of a robot at a node.

  `solve_fast.sh <instance-name>`

- For options:

  `solve_fast.sh -h`

- In particular to run a high-performance variant:

  `solve_fast.sh -v t1_corr2_lb2_mh1 instances/sp/20x4_15_1_75_100_2_6_3_replenish_many_edges.lp`

- NOTE: The naming of `fast` and `full` is misleading. The `full` path encoding is often faster

### Path Encoding Variants Explained

- This provides a very rough explanation of the main solving options: `t1_corr2_lb2_mh1`:

  - `t1` refers to the use of additional acyclicity checking for the task
    assignment/sequencing problem (the assignment of tasks to robots and the
    task order for each robot).
  - `corr2` refers to restricting the path for each robot to a "corridor" that
    is defined around each path's shortest path. This can dramatically reduce
    the grounding of the problem.
  - `lb2` refer to the use of a solving time lower bound that can be determined
    from the shortest path. This can help generally but is important for
    minimising the makespan and determining if the problem is unsatisfiable.
  - `mh1` refers to the use of a move heuristic. The move heuristic prefers the
    robot to choose it's minimal path. This provides the greatest performance
    improvement.



