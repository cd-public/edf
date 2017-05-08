# rt-proofs

This contains the files of rt-proofs related to the proof of the optimality of EDF, which are part of a course project.

For now:


I am using code from this repository:  https://gitlab.mpi-sws.org/RT-PROOFS/rt-proofs

I rename rt-proofs to rt.

I place all code in new directory rt/edf.  I place erase, insert, and swap in rt/edf/transformation.

I was able to get everything running in the interpreter but there are no proof scripts yet.  I had to compile demand and total_service to do this.  I did total_service first then demand by calling "coqc -R rt rt rt/edf/total_service" from the parent directory containing rt.
