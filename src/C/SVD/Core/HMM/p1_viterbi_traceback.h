#ifndef VITERBI_TRACEBACK_HEADER
#define VITERBI_TRACEBACK_HEADER

#include<stdio.h>
#include<math.h>
#include"p1_viterbi_matrices.h"
#include"p1_profile.h"

void p1_viteri_traceback(struct p1_viterbi_matrices mtx, struct p1_profile prof, int dsequence[], int vtrace[]);

#endif
