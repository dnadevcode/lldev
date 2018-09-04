#ifndef PROFILE_HEADER
#define PROFILE_HEADER
/*  Plan-1 HMM profile structure.
 *  o
 *  
 */ 

typedef struct emissions {
    double *Mf, *Mr;
} emissions;

typedef struct transitions {
    double *Ef, *Er;
    double *N;
    double *Jf, *Jr;
    double *C;
    double *Mf, *Mr;
    double *Bf, *Br;
} transitions;

typedef struct p1_profile {
    int length;
    struct emissions em;
    struct transitions tr;
} p1_profile;

#endif
