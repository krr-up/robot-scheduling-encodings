# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, StringField, IntegerField

class Task(Predicate):
    tid=ConstantField
    vertex=ConstantField

class Assignment(Predicate):
    rid=ConstantField
    tid=ConstantField

class TaskSequence(Predicate):
    first=ConstantField
    second=ConstantField
    class Meta: name="task_sequence"

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    raise RuntimeError('Cannot run modules')
