echo Synchronized

for thread in 1 2 4 8 12 16 24
do
    echo Thread=$thread Swaps Fixed at 10,000
    java UnsafeMemory Synchronized $thread 10000 127 5 120 3 69 3
done

for iterations in 1000 10000 100000
do
    echo SwapCount=$iterations Threads Fixed at 8
    java UnsafeMemory Synchronized 8 $iterations 127 5 120 3 69 3
done
echo Donezo