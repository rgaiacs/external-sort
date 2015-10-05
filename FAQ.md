# FAQ

1.  This program is likely to be I/O bound.
    Is there any way to take advantage of this?
    Or to minimize costs?
    How does Julia work for I/O bound tasks?

    Is possible to implement the external sort using asynchronous I/O
    and we can let each machine does as much work as possible.
    For example, we can send unsorted chunck of data
    to each machine and let it sort that chunck before write to disk.

    Julia offer all the features from other parallel enviroments
    and how data will be move is up to the programmer.

2.  Are there parts of the program that can be parallelized across:

    1.  multiple cores in the same machine?

        Yes. The local sort of data can be parallelized.

    2.  multiple disks in the same machine?

        Yes. We can write the sorted files in different disks.

    3.  multiple machines?

        Yes. Sort the small files could be done in multiple machines.
