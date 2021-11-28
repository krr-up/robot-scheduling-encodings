"""Parse an OSM xml file."""

# ------------------------------------------------------------------------------
# G = osm_parser.parse(filename)
#
# Returns a networkx graph G where nodes have a string identifier with
# attributes "lat" and "lon" (representing lattitude and longitude as floats)
# and "nattr" (representing node type as a string). Edges, are between the
# string identifiers and a weight attribute in meters.
#
# ------------------------------------------------------------------------------

import logging
import math
from lxml import etree
import networkx as nx
from geopy import distance
from dataclasses import dataclass

# Module level logger
g_logger = logging.getLogger(__name__)

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------


@dataclass
class Grid:
    """The rectangular size of the map."""

    x: int
    y: int

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

def node_loc(G,nid):
    return (G.nodes[nid]["lat"], G.nodes[nid]["lon"])

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

def on_node(G,node):
    attrib = node.attrib
    nid = str(attrib['id'])
    lat = float(attrib['lat'])
    lon = float(attrib['lon'])
    nattr = {}
    for tag in node.getchildren():
        if tag.tag == "tag":
            attrib = tag.attrib
            if "k" not in attrib or "v" not in attrib:
                raise RuntimeError(("Node %s: invalid tag missing either "
                                    "'k' or 'v'"), nid)
            nattr[attrib["k"]] = attrib["v"]
    G.add_node(nid, lat=lat, lon=lon, nattr=nattr)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def on_way(G,way):
    wid = way.attrib["id"]
    prev = None
    for nd in way.getchildren():
        #  print("ND: {} => {}".format(nd.tag,nd.attrib))
        if nd.tag == "nd":
            curr = str(nd.attrib["ref"])
            if prev:
                nfrom = node_loc(G, prev)
                nto = node_loc(G, curr)
                dist = distance.distance(nfrom, nto).meters
                # print("DIST FROM {} to {} IS {}".format(nfrom,nto,dist))
                G.add_edge(prev, curr, weight=dist)
            prev = curr
    if not prev:
        raise RuntimeError("Missing nodes in wid {}".format(wid))

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def parse(filename):
    """Parse a OSM file and return a (graph,bounds) pair."""
    G = nx.DiGraph()
    logging.info("Parsing: {}".format(filename))
    osm = etree.parse(filename).getroot()
    for child in osm.getchildren():
        if child.tag == "node":
            on_node(G, child)
        elif child.tag == "way":
            on_way(G, child)

    lat = nx.get_node_attributes(G, "lat")
    lon = nx.get_node_attributes(G, "lon")
    lats = [lat[n] for n in G.nodes]
    lons = [lon[n] for n in G.nodes]
    lat_max = max(lats)
    lat_min = min(lats)
    lon_max = max(lons)
    lon_min = min(lons)
    x = distance.distance((lat_max, lon_min), (lat_max, lon_max)).meters
    y = distance.distance((lat_min, lon_max), (lat_max, lon_max)).meters
    grid = Grid(x=math.ceil(x), y=math.ceil(y))

    return (G, grid)

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------


if __name__ == "__main__":
    raise RuntimeError('Cannot run modules')
