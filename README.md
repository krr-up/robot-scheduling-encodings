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

- There are two Difference Logic (DL) based encodings: _walk_ encoding and
  _path_ encoding.
- The two encodings are the same in how they assign tasks to robots and the
  sequence in which the tasks are executed.
- However, they vary in how they assign the movements of the robots:
- The walk encoding is the most general and intuitive, and matches closely to
  the formalization:
  - Each robot is assigned a sequence of moves that traverses the graph from
    its starting location and must end at its home location.
  - The sequence of moves is a _walk_ through the graph, since it can visit any
    given vertex multiple times.
  - A given robot's walk must visit the appropriate task's vertex in the
    correct order.
  - A walk encoding requires the specification of a step horizon, which is the
    maximum number of steps allowed for any one robot.
- In contrast to the walk encoding, the path encoding adds an abstraction layer
  by constructing the moves of a robot in terms of a set of distinct paths:
  - Each task is associated with a path; and there is also a return home path
    for each robot.
  - A path traverses the graph from a source to a destination vertex but a
    single path can visit a given vertex only once.
  - Moves are chosen at the path level; with the additional requirements to
    ensure that the sequence of paths assigned to a given robot must match up.
  - The path encoding does not require the specification of a horizon.
- There are two additional things to note:
  - The robot/path move choices are independent of timing. The move assignment
    is handled in ASP while the the timing of when a robot arrives and leaves a
    vertex is handled by the DL constraints. This dramatically reduces the
    state space for both the walk and path encodings.
  - Every path encoding solutions can be mapped to a walk encoding solution
    (with an appropriate step horizon). The opposite does not hold, so the walk
    encoding is strictly more general than the path encoding. This can be
    realised simply by the fact that in the walk encoding a robot can visit a
    vertex any number of times, whereas for the path encoding a robot can visit
    a vertex only once as part of any given path.

## Common encoding enhancements

- There are some additional rules that can be added to the encoding that can
  potentially improve performance.

- _Task sequence acyclicity_. This variant applies to both the walk and path
  encodings. The pure ASP code to assign tasks to robots and to construct a
  sequence of tasks for a given robot can generate some invalid task
  sequences. In particular, there can be cyclic task sequences. Only when it is
  combined with the DL timing constraints that these invalid sequences are
  removed. To acheive a pure ASP correct assignment requires ensuring that the
  task sequences are acyclic. This variant uses Clingo's special support for
  cycle detection.

## Common encoding variant

- We consider two variants for generating the task sequences:
  - The default is to use a single choice rule to connect any two tasks in the
    sequence.
  - A second variant uses two choice rules to connect task sequences; by
    chosing who to connect to and who to connect from. While technically
    redundant this second rule can potentially improve performance (especially
    as the number of tasks increase). Note: more experiments required.

## Shortest path information

- There are some enhancements that can take advantage of pre-computed _shortest
  path_ information for the graph.
- The rationale is that a graph corresponds to a given warehouse and so this
  graph will rarely change. Therefore pre-computing shortest path information
  for the graph is a one-off cost that can be computed off-line.
- For the sake of our testing framework we run the shortest path calculation on
  each problem instance (which includes both the graph and tasks) to generate
  the supplementary shortest path information for that instance.


## Path encoding enhancements

- The path encoding allows for a number of additional rules to provide improved
  performance. These improvements are based on using the shortest path data for
  each instance.

- _Corridor limted moves_. By default the moves of any given path can range
  over any vertex in the graph; provided it ends at the appropriate vertex. The
  corridor concept restricts the allowable moves associated with a path to a
  more restricted set of vertices based around the shortest path from the
  source to the destination vertex.

- _Lower bounds_. Using the shortest path information it is possible to
  determine a realistic lower bounds for the shortest time it could possibly
  take for a robot to arrive at a path destination from a given source. This
  can help general solving; but is particularly important if we want to
  calculate the minimum makespan.

- _Move domain heuristic_. Domain heuristics allow for domain information to be
  injected into Clingo's heuristic search algorithm. The move heuristic guides
  the move choices to those are likely to be both correct and good. In
  particular moves along the shortest paths are preferred over longer routes.

## Pallet replacement bound

- In order to provide bounded behaviour some rules can be added to enforce a
  strict time limit on the time between the pickup of an item and the putdown
  of its replacement empty pallet.

- This enhancement works best on a structured environment (rather than randomly
  generated data) to determine what are reasonable bounds.


## Running

### Computing Shortest Paths

- There are a number of different solving options. But the high-performance
  options rely on pre-computed shortest path information.
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


### Path Encoding


  `solve_full.sh <instance-name>`

- For options:

  `solve_full.sh -h`

- In particular to run a high-performance variant:

  `solve_full.sh -v tsa_corr_lb_mh instances/sp/20x4_15_1_75_100_2_6_3_replenish_many_edges.lp`


### Fast Path Encoding

- Tracks only the arrival times of a robot at a node.

  `solve_fast.sh <instance-name>`

- For options and an explanation of the different variants:

  `solve_fast.sh -h`

- In particular to run a high-performance variant:

  `solve_fast.sh -v t1_corr2_lb2_mh1 instances/sp/20x4_15_1_75_100_2_6_3_replenish_many_edges.lp`

