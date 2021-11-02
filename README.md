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


## Basics of the different encodings

- There are two Difference Logic (DL) based encodings: _walk_ encoding and _path_ encoding.
- The two encodings are the same in how they assign tasks to robots and the
  sequence in which the tasks are executed.
- However, they vary in how they assign the movements of the robots:
- The walk encoding is the most general and intuitive.
  - Each robot is assigned a sequence of moves that traverses the graph from
    its starting location through and must end at its home location.
  - The sequence of moves is a _walk_ through the graph since it can visit any
    given vertex multiple times.
  - A given robot's walk must visit the appropriate task's nodes in the correct
    order.
- The path encoding adds an abstraction layer by constructing the moves of a
  robot in terms of a set of distinct paths.
  - Each task is associated with a path; and there is also a return home path
    for each robot.
  - A path traverses the graph from a source to a destination vertex but can
    visit a given vertex only once.
  - moves are chosen at the path level; with the additional requirements to
    ensure that the sequence of paths assigned to a given robot must match up.
- There are two more important things to note:
  - The robot/path move choices are independent of timing. The move assignment
    is handled in ASP while the the timing of when a robot arrives and leaves a
    vertex is handled by the DL constraints. This dramatically reduces the
    state space for bot the walk and path encodings.
  - The path encoding solutions are a proper subset of the walk encoding
    solutions. For the walk encoding a robot could visit a vertex any number of
    times, whereas for the path encoding a robot can visit a vertex only once
    as part of any given path.

## Path encoding variants

- The path encoding allows for a number of additional rules to provide improved
  performance.

- These improvements are based around pre-computing _shortest path_ information
  for the graph.

- The rational is that a graph corresponds to a given warehouse and so this
  graph is will rarely change. Therefore pre-computing shortest path
  information for the graph is a one-off cost that can be computed off-line.

- _Corridor limted moves_. By default the moves of any given path can range
  over any vertex in the graph; provided it ends at the appropriate vertex. The
  corridor concept restricts the allowable moves associated with a path to a
  more restricted set of vertices based around the shortest path from the
  source to the destination vertex.

- _Lower bounds_. Using the shortest path information it is possible to
  determine a realistic lower bounds for the shortest time it could possibly
  take for a robot to arrive at a path destination from a given source.






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



