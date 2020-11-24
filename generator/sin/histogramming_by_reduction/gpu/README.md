# Reduction with CUDA Thrust

THREAD=4, GPU=1

grep THREAD_NUM multi12.cpp
<pre>
#define WORKER_THREAD_NUM 5                                    
</pre>

grep GPU_number kernel.cu -rin
<pre>
37:    // int GPU_number = thread_id % 4;
38:    int GPU_number = 0;
76:    int GPU_number = 0;
</pre>

<pre>
# ./build.sh rand_gen
# time ./rand_gen 10000
# split -l 1000 random_data.txt 
# mv x* ./data/
#  ./build-traverse.sh multi12
#  time ./multi12 data/
</pre>

When you are to change # of GPU to more than one, change GPU_number (kernel.cu).
