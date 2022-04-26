#!/bin/bash
for file in *.json; do
	truncate -s -2 $file;
	printf '%s\n%s\n' "{\"permissions\":[" "$(cat $file)" > $file;
	echo "]}" >> $file;
done
