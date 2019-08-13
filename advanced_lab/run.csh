#!/bin/csh
foreach n (`seq 1 1 16`)
    env OMP_NUM_THREADS=$n srun -n 1 ./shwater2d
end
