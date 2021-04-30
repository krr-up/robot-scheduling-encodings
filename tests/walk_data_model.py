# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, StringField, IntegerField, RawField

class Walk(Predicate):
    rid=RawField
    step=IntegerField
    vertex=RawField

class Proj(Predicate):
    tid=RawField
    step=IntegerField

class Arrive(Predicate):
    rid=RawField
    step=IntegerField

class Exit(Predicate):
    rid=RawField
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
