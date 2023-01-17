# qsharp-scheduling-optimization

Draft Q# version.

Organizing a small conference.

Np=50 participants (P1 to P50) and Nt=13 talks (T1 to T13).
There are 5 time spots each with 5 rooms available.

T1 will be given 3 times, T2 to T7 will be given 2 times each and T8
to T13 will be given only once. Consequently there are 22 talks. The
constraint is that the repeated talks should not be scheduled in the
same time slot.

Each participant has given his preference to which talk to attend, 
from 1st preference to 8th preference. And each participant should
attend 5 talks, one in each time slot.

Problem: What talks should be scheduled in each time slot so to optimize the preferences?

Ref. Link: http://www.amsterdamoptimization.com/scheduling.html
