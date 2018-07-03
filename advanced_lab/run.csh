#!/bin/csh
foreach n (`seq 1 1 16`)
    env OMP_NUM_THREADS=$n aprun -n 1 -d $n ./shwater2d
end
