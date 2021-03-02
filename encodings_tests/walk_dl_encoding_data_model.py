# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, StringField, IntegerField

class Walk(Predicate):
    rid=ConstantField
    step=IntegerField
    vertex=ConstantField

class Proj(Predicate):
    tid=ConstantField
    step=IntegerField

class Arrive(Predicate):
    rid=ConstantField
    step=IntegerField

class Exit(Predicate):
    rid=ConstantField
    step=IntegerField

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
