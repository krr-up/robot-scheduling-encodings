#!/usr/bin/env python

# ------------------------------------------------------------------------------
# Takes an instance file and generates a new instance that includes shortest
# path information.
# ------------------------------------------------------------------------------
import logging
import os
import math
import sys
import numpy as np
#from numpy import array, asarray, inf, zeros, minimum, diagonal, newaxis

from clorm import Predicate, StringField, IntegerField, ConstantField, \
    RawField, make_function_asp_callable, simple_predicate

from clorm.clingo import Control

# Module level logger
g_logger = logging.getLogger(__name__)

#-------------------------------------------------------------------------------
# A Map that defines the travel time between nodes and also distinguishes the
# nodes that are endpoints.
# ------------------------------------------------------------------------------

class TTMap(object):
    def __init__(self):
        self._node_stoi={}          # Match node name to an array index
        self._node_itos=[]          # Match node array index to name
        self._endpoints=set([])     # The endpoints (by index)
        self._conns={}              # The edges in the graph

    # Get the node index (either existing or creating a new one)
    def _node_idx(self,name):
        idx = self._node_stoi.get(name)
        if idx is None:
            idx = len(self._node_itos)
            self._node_stoi[name] = idx
            self._node_itos.append(name)
            assert idx == len(self._node_itos)-1
        return idx

    def register_endpoint(self,node):
        idx = self._node_idx(node)
        self._endpoints.add(idx)

    def add_conn(self,n1,n2,tt):
        ttint=(tt)
        idx1 = self._node_idx(n1)
        idx2 = self._node_idx(n2)

        tmp1 = self._conns.get(idx1)
        if tmp1 is None:
            tmp1 = {}
            self._conns[idx1] = tmp1
        tmptt = tmp1.get(idx2)
        if tmptt is not None and tmptt != ttint:
            msg=("Multiple edge values from node {} to {}: {} and "
                 "{}".format(n1,n2,tmptt,ttint))
            g_logger.fatal(msg)
            raise ValueError(msg)
        tmp1[idx2] = ttint

    def make_adjacency_matrix(self):
        count=len(self._node_itos)
#        mat=np.full(shape=(count,count),fill_value=np.inf,dtype=np.int32)
        mat=np.full(shape=(count,count),fill_value=np.inf)
        np.fill_diagonal(mat,0)

        for idx1, tmp1 in self._conns.items():
            for idx2, tt in tmp1.items():
                mat[idx1,idx2]=tt
        return mat

    def node_name(self,idx):
        return self._node_itos[idx]

    def connections(self,idx1=None):
        if idx1 is not None:
            return [idx2 for idx2 in self._conns[idx1].keys()]
        out=[]
        for idx1,tmp in self._conns.items():
            out.extend([(idx1,idx2) for idx2 in self._conns[idx1].keys()])
        return out

    @property
    def endpoints_vector(self):
        count=len(self._node_itos)
        v=np.full(shape=count,fill_value=0)
        for idx in range(count):
            if idx in self._endpoints: v[idx] = 1
        return v

    @property
    def endpoints(self): return self._endpoints

    @property
    def num_nodes(self): return len(self._node_itos)

# ------------------------------------------------------------------------------
# Fast version of FloydWarshal taken from: https://gist.github.com/mosco/11178777
# ------------------------------------------------------------------------------

def floydwarshall(mat_in):
    mat=np.array(mat_in)
    count=mat.shape[0]
    for k in range(count):
        mat = np.minimum(mat, mat[np.newaxis,k,:] + mat[:,k,np.newaxis])
    return mat

# ------------------------------------------------------------------------------
# For each node and each endpoint work out the shortest distance to that
# endpoint and the next node on that route.
# ------------------------------------------------------------------------------

def make_min_tt_via1(ttmap, orig_mat, min_mat):
    if np.inf in min_mat:
        msg=("The graph contains unreachable nodes. A partitioned graph "
             "should be treated as distinct problems with separate graphs")
        g_logger.fatal(msg)
        raise AssertionError(msg)
    output=[]
    for ep in ttmap.endpoints:
        epname = ttmap.node_name(ep)
        min_ep1 = min_mat[:,ep]
        min_ep2 = min_ep1[np.newaxis,:]
        tmp = orig_mat+min_ep2
        tmp = (tmp == tmp.min(axis=1)[:,None]).astype(int)
        np.fill_diagonal(tmp,0)
        tmp2=np.argwhere(tmp>0)

        for idx1,idxv in tmp2:
            min_tt = min_ep1[idx1]
            output.append((ttmap.node_name(idx1),epname,int(min_tt),
                           ttmap.node_name(idxv)))
    return output

def make_min_tt_via2(ttmap, orig_mat, min_mat):
    if np.inf in min_mat:
        msg=("The graph contains unreachable nodes. A partitioned graph "
             "should be treated as distinct problems with separate graphs")
        g_logger.fatal(msg)
        raise AssertionError(msg)

    output=[]
    count=min_mat.shape[0]
    for idx1 in range(count):
        n1 = ttmap.node_name(idx1)
        adjacents = ttmap.connections(idx1)
        for idx2 in ttmap.endpoints:
            if idx1 == idx2: continue
            n2 = ttmap.node_name(idx2)
            min_tt = min_mat[idx1,idx2]

            # We have a src-dst and min tt. Now work out the via node
            found=False
            for idxv in adjacents:
                if orig_mat[idx1,idxv]+min_mat[idxv,idx2] <= min_tt:
                    nv = ttmap.node_name(idxv)
                    if found:
                        msg="Multiple shortest routes from %s to %s"
                        g_logger.debug(msg,idx1,idx2)
                    found=True
                    output.append((n1,n2,int(min_tt),nv))

            if not found:
                msg="No shortest path route from {} to {}".format(idx1,idx2)
                g_logger.fatal(msg)
                raise AssertionError(msg)
    return output

make_min_tt_via=make_min_tt_via2

#-------------------------------------------------------------------------------
# ASP callable functions and clorm interfaces for interacting with a ASP.
# -------------------------------------------------------------------------------

# Define the predicates to be exported

Edge           = simple_predicate("edge",3)
Robot          = simple_predicate("robot",1)
Home           = simple_predicate("home",2)
Start          = simple_predicate("start",2)
Conflict       = simple_predicate("conflict",3)
Task           = simple_predicate("task",2)
Depends        = simple_predicate("depends",3)


Nearest        = simple_predicate("nearest",3)
EntryPoint     = simple_predicate("entrypoint",3)
OnDeadEnd      = simple_predicate("on_deadend",2)
EndpointAccess = simple_predicate("endpoint_access",2)
ShortestPath   = simple_predicate("shortest_path",4)

# -------------------------------------------------------------------------------
# ASP callable functions
# -------------------------------------------------------------------------------

g_ttmap = TTMap()

SF=StringField; IF=IntegerField; CF=ConstantField; RF=RawField

# Gather the connections (edges) in the graph
@make_function_asp_callable
def gather_edge(v1 : RF, v2 : RF, d : IF) -> IF:
    global g_ttmap
    g_ttmap.add_conn(v1,v2,d)
    return 0

# Gather the nodes
@make_function_asp_callable
def gather_endpoint(v : RF) -> IF:
    global g_ttmap
    g_ttmap.register_endpoint(v)
    return 0

# Populate the shortest paths from every vertex to every endpoint vertex.
# Returns a list of tuples (V,EP,V',D) where the shortest path from vertex V to
# end EP is distance D and via vertex V'.
@make_function_asp_callable
def shortest_paths() -> [(RF,RF,IF,RF)]:
    global g_ttmap
    mat = g_ttmap.make_adjacency_matrix()
    min_mat = floydwarshall(mat)
    return make_min_tt_via(g_ttmap,mat,min_mat)

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
SCRIPT_DIR=os.path.dirname(os.path.abspath(__file__))
SPFILE=os.path.join(SCRIPT_DIR,"shortest_paths.lp")

def main():

    # Setup the clingo control object
    ctrl = Control(unifier=[Edge,Robot,Home,Start,Conflict,Task,Depends,
                            Nearest,EntryPoint,OnDeadEnd,EndpointAccess,ShortestPath])
    ctrl.load(SPFILE)

    # Load the instance
    if len(sys.argv) <= 1:
        g_logger.fatal("Missing input instance")
        return
    elif len(sys.argv) == 2 and sys.argv == "-":
        g_logger.fatal("READ FROM STDIN")
        return
    else:
        for arg in sys.argv[1:]:
            g_logger.info("Loading instance from {}".format(arg))
            ctrl.load(arg)

    # Ground, solve and print the output
    fb=None
    ctrl.ground([("base",[])])
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(atoms=True)
            print("{}".format(fb.asp_str()))
            return

    if fb is None:
        raise SystemError("Unsatisfiable")

    sys.stderr.flush()
    sys.stdout.flush()


# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    main()
