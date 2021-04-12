# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

from clorm import Predicate, ConstantField, IntegerField, RawField

class Task(Predicate):
    tid=RawField
    vertex=RawField

class Assignment(Predicate):
    rid=RawField
    tid=RawField

class TaskSequence(Predicate):
    first=RawField
    second=RawField
    class Meta: name="task_sequence"

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    raise RuntimeError('Cannot run modules')
