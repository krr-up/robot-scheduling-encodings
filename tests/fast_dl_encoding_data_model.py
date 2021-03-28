# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, StringField, IntegerField

class Path(Predicate):
    pid=ConstantField
    vertex=ConstantField

class Move(Predicate):
    pid=ConstantField
    fvertex=ConstantField
    tvertex=ConstantField

class Visit(Predicate):
    pid=ConstantField
    vertex=ConstantField

class Arrive(Predicate):
    pid=ConstantField
    vertex=ConstantField

class DlArrive(Predicate):
    a=Arrive.Field
    t=IntegerField
    class Meta: name = "dl"

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    raise RuntimeError('Cannot run modules')
