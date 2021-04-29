# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, IntegerField, RawField

class Path(Predicate):
    pid=RawField
    vertex=RawField

class Move(Predicate):
    pid=RawField
    fvertex=RawField
    tvertex=RawField

class Visit(Predicate):
    pid=RawField
    vertex=RawField

class Arrive(Predicate):
    pid=RawField
    vertex=RawField

class Exit(Predicate):
    pid=RawField
    vertex=RawField

class DlArrive(Predicate):
    a=Arrive.Field
    t=IntegerField
    class Meta: name = "dl"

class DlExit(Predicate):
    e=Exit.Field
    t=IntegerField
    class Meta: name = "dl"


# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    raise RuntimeError('Cannot run modules')
