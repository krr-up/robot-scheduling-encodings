# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, StringField, IntegerField

class Move(Predicate):
    tid=ConstantField
    fvertex=ConstantField
    tvertex=ConstantField

class Visit(Predicate):
    tid=ConstantField
    vertex=ConstantField

class Arrive(Predicate):
    tid=ConstantField
    vertex=ConstantField

class Exit(Predicate):
    tid=ConstantField
    vertex=ConstantField

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
