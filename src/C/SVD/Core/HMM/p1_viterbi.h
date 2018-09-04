#ifndef VITERBI_HEADER
#define VITERBI_HEADER

#include<stdio.h>
#include<stdlib.h>
#include"p1_profile.h"
#include"p1_general.h"
#include"p1_viterbi_matrices.h"

struct p1_viterbi_matrices viterbi(struct p1_profile prof, int dsequence[], struct p1_viterbi_matrices vout);

#endif
