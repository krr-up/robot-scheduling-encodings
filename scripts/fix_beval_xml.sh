#!/usr/bin/env sh

# Fix bad xml because it messes up the command line with having a double quotes embedded in double
# quoutes. So we turn the internal double quotes into a single qoutes.

sed -i 's/"${HOME}/\x27${HOME}/g' $@
sed -i 's/-""/-\x27"/g' $@


