#!/bin/bash

for i in {1..100}
do
    echo $i
    tarantool dml.lua &
done
