THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export PATH="${THIS_DIR}/scripts:${PATH}"

# Bug in clingo 5.5.0?
export PYTHONPATH="."

