
#SEARCH="Child ended because it received signal 9 (SIGKILL)"

#echo "$(rg $SEARCH | sed -e 's/:$SEARCH//')"

#for file in $(<tmp.txt)
#for file in $(rg "Child ended because it received signal 9 \(SIGKILL\)" | sed -e 's@:Child ended because it received signal 9 (SIGKILL)@@')
#do
#    echo "File: $file"
#    echo $(dirname $file)
#done
#for file in $(rg "Child ended because it received signal 9 \(SIGKILL\)" | sed -e 's@:Child ended because it received signal 9 (SIGKILL)@@')


for file in $(rg -l "Child ended because it received signal 9 \(SIGKILL\)")
do
    dirname=$(dirname $file)
    solverfile="$dirname/runsolver.solver"
    if [ ! -f $solverfile ]; then
        echo "Missing solver file: $solverfile"
        continue
    fi
    result=$(tail -n 1 "$solverfile")
    if [[ "$result" =~ Cost\ backward ]]; then
        :
        #    echo "Result: $file: $solverfile"
#        echo "Good: $solverfile"
    else
        echo "Bad: $file"
    fi
done
