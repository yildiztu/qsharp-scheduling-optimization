/*
Organizing a small conference. Draft Q# version.

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
*/
// Ref. Link: http://www.amsterdamoptimization.com/scheduling.html


open Microsoft.Quantum.Optimization;

operation SolveConferenceSchedulingProblem(qs: Qubit[]): Unit {
    let numParticipants = 50;
    let numTalks = 13;
    let numTimeSlots = 5;
    let numRooms = 5;

    // Define the number of occurrences of each talk
    let talkOccurrences = [3, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1];

    // Define the participant's preferences
    let preferences = [
      [1, 2, 3, 4, 5, 6, 7, 8],
      [2, 1, 3, 4, 5, 6, 7, 8],
      [3, 1, 2, 4, 5, 6, 7, 8], ...
    ];

    // Define the objective function as the total number of preferred talks attended
    let f(x: Double[]): Double {
      let totalPreferredTalks = 0.0;
      for (i in 0 .. numParticipants - 1) {
        for (t in 0 .. numTalks - 1) {
          for (s in 0 .. numTimeSlots - 1) {
            for (r in 0 .. numRooms - 1) {
              let talkIndex = i * numTalks * numTimeSlots * numRooms + t * numTimeSlots * numRooms + s * numRooms + r;
              totalPreferredTalks += x[talkIndex] * (preferences[i].IndexOf(t) + 1);
            }
          }
        }
      }
      return totalPreferredTalks;
    }

    // Define the linear constraints
    let g(x: Double[]): Double[] {
      let constraints = new Double[numParticipants + numTalks * numTimeSlots * numRooms + numTimeSlots * numRooms];
      for (i in 0 .. numParticipants - 1) {
        let constraintIndex = i;
        constraints[constraintIndex] = 0.0;
        for (t in 0 .. numTalks - 1) {
          for (s in 0 .. numTimeSlots - 1) {
            for (r in 0 .. numRooms - 1) {
              constraints[constraintIndex] += x[i * numTalks * numTimeSlots * numRooms + t * numTimeSlots * numRooms + s * numRooms + r];
            }
          }
        }
        constraints[constraintIndex] == 5.0;
      }
      for (t in 0 .. numTalks - 1) {
        for (s in 0 .. numTimeSlots - 1) {
          let constraintIndex = numParticipants + t * numTimeSlots * numRooms + s * numRooms;
          constraints[constraintIndex] = 0.0;
          for (r in 0 .. numRooms - 1) {
            for (i in 0 .. numParticipants - 1) {
              constraints[constraintIndex] += x[i * numTalks * numTimeSlots * numRooms + t * numTimeSlots * numRooms + s * numRooms + r];
            }
          }
          constraints[constraintIndex] == talkOccurrences[t] * numRooms;
        }
      }

      for (t in 0 .. numTalks - 1) {
        for (s1 in 0 .. numTimeSlots - 1) {
          for (s2 in s1 + 1 .. numTimeSlots - 1) {
            let constraintIndex = numParticipants + numTalks * numTimeSlots * numRooms + (t * numTimeSlots * (numTimeSlots - 1)) / 2 + s1 * (numTimeSlots - 1) + s2;
            constraints[constraintIndex] = 0.0;
            for (r in 0 .. numRooms - 1) {
              constraints[constraintIndex] += x[t * numTimeSlots * numRooms + s1 * numRooms + r];
              constraints[constraintIndex] += x[t * numTimeSlots * numRooms + s2 * numRooms + r];
            }
            constraints[constraintIndex] <= talkOccurrences[t];
          }
        }
      }
      return constraints;
    }

    // Define the upper and lower bounds on the variables
    let bounds = new Interval[numParticipants * numTalks * numTimeSlots * numRooms];
    for (i in 0 .. numParticipants * numTalks * numTimeSlots * numRooms - 1) {
      bounds[i] = (0.0, 1.0);
    }

    // Define the initial point
    let x0 = new Double[numParticipants * numTalks * numTimeSlots * numRooms];
    for (i in 0 .. numParticipants * numTalks * numTimeSlots * numRooms - 1) {
      x0[i] = 0.0;
    }

    // Define the tolerance for the solver
    let tolerance = 1e-9;

    // Define the maximum number of iterations for the solver
    let maxIterations = 1000;

    // Solve the optimization problem
    let result = Solve(qs, f, g, bounds, x0, tolerance, maxIterations);

    // Print the results
    let scheduledTalks = new Int[numTimeSlots, numRooms];
    for (s in 0 .. numTimeSlots - 1) {
      for (r in 0 .. numRooms - 1) {
        scheduledTalks[s, r] = -1;
        for (t in 0 .. numTalks - 1) {
          for (i in 0 .. numParticipants - 1) {
            if (x[i * numTalks * numTimeSlots * numRooms + t * numTimeSlots * numRooms + s * numRooms + r] == 1) {
              scheduledTalks[s, r] = t;
            }
          }
        }
      }
    }

    // Print the scheduled talks
    for (s in 0 .. numTimeSlots - 1) {
      for (r in 0 .. numRooms - 1) {
        Message($ "Time slot {s + 1}, Room {r + 1}: Talk {scheduledTalks[s, r] + 1}");
      }
    }
