set terminal png 
set autoscale
set output "schedule.png" 
set xlabel "Iteration"
set ylabel "Thread ID"
unset key
plot "schedule.dat" using 1:2 ls 4