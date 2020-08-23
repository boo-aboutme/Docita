#! /usr/bin/bash

src=$1
shift
srcs="$*"
base=`basename $src .v`
target="$base".iv

iverilog -o $target $src $srcs
if [ $? -eq 0 ]; then
	vvp $target
	echo "$target done"
else
	echo ""
fi
