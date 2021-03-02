# robot-scheduling-encodings
Encodings and benchmarking for the robot-scheduling paper

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

- `encodings`        : directory for different encodings
- `encodings_tests` : tests for debugging the encodings
- `scripts`          : bash scripts
- `instances`        : Put instances here?
- `generator`        : The instance generator?


## Installation

### General

`clingo` and `clingo-dl` need to be installed:

    conda install -c potassco clingo
    conda install -c potassco clingo-dl

### Encoding testing

For testing the encoding install `networkx` and you need the dev version of `clorm`:

    conda install networkx
    conda install -c potassco/label/dev clorm


