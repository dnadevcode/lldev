#include"p1_viterbi.h"
#include<mex.h>



struct p1_viterbi_matrices viterbi(struct p1_profile prof, int *dsequence, struct p1_viterbi_matrices vout)
{
    float sc;
    int L, M, i, st;
    M = prof.length;
    /* The sequence length is stored as the first element in the sequence array */
    L = dsequence[0];
    
    for(st=0; st<=M; st++) {
        vout.MfMX[st] = vout.MrMX[st] = -INFINITY;    
    }

    /* Init step*/
    vout.NMX[0] = 0;
    vout.BfMX[0] = prof.tr.N[0];
    vout.BrMX[0] = prof.tr.N[1];
    vout.EfMX[0] = vout.ErMX[0] = vout.JfMX[0] = vout.JrMX[0] = vout.CMX[0] = -INFINITY;
    for(st=0; st<=M; st++) {
        vout.MfMX[st] = vout.MrMX[st] = -INFINITY;
    }
    /* Loop */
    for(i=1; i<=L; i++) {
        vout.EfMX[i] = vout.ErMX[i] = -INFINITY;
        /* first Mf */
        vout.MfMX[i*(M+1) + 1] =\
            MAX((vout.MfMX[(i-1)*(M+1) + M] + prof.tr.Mf[M]),
                 (vout.BfMX[i-1] + prof.tr.Bf[0]));
        vout.MfMX[i*(M+1) + 1] += prof.em.Mf[1 + ((dsequence[i]-1)*(M+1))];
        /* First Mr */
        vout.MrMX[i*(M+1) + 1] =\
            MAX((vout.MrMX[(i-1)*(M+1) + M] + prof.tr.Mr[M]),
                 (vout.BrMX[i-1] + prof.tr.Br[0]));
        vout.MrMX[i*(M+1) + 1] += prof.em.Mr[1 + ((dsequence[i]-1)*(M+1))];

        /* first Ef */
        vout.EfMX[i] =\
            MAX((vout.MfMX[i*(M+1) + 1] + prof.tr.Mf[M+1]),
                 vout.EfMX[i]);
        /* First Er */
        vout.EfMX[i] =\
            MAX((vout.MfMX[i*(M+1) + 1] + prof.tr.Mf[M+1]),
                 vout.EfMX[i]);



        for(st=2; st<=M; st++) {
            /* Match forward */
            vout.MfMX[i*(M+1) + st] =\
                MAX((vout.MfMX[(i-1)*(M+1) + (st-1)] + prof.tr.Mf[st-1]),
                    (vout.BfMX[i-1] + prof.tr.Bf[st-1]));
            vout.MfMX[i*(M+1) + st] += prof.em.Mf[st + ((dsequence[i]-1)*(M+1))];
            /* Match reverse*/   
            vout.MrMX[i*(M+1) + st] =\
                MAX((vout.MrMX[(i-1)*(M+1) + (st-1)] + prof.tr.Mr[st-1]),
                    (vout.BrMX[i-1] + prof.tr.Br[st-1]));
            vout.MrMX[i*(M+1) + st] += prof.em.Mr[st + ((dsequence[i]-1)*(M+1))];
            /* End forward */
            vout.EfMX[i] =\
                MAX((vout.MfMX[i*(M+1) + st] + prof.tr.Mf[st+M]),
                     vout.EfMX[i]);
            /* End reverse */
            vout.ErMX[i] =\
                MAX((vout.MrMX[i*(M+1) + st] + prof.tr.Mr[st+M]),
                     vout.ErMX[i]); 
        
        }
        /* J states */
        vout.JfMX[i] = MAX(vout.JfMX[i-1] + prof.tr.Jf[1],
                           vout.EfMX[i] + prof.tr.Ef[0]);
        vout.JfMX[i] = MAX(vout.JfMX[i],
                           vout.ErMX[i] + prof.tr.Er[1]);

        vout.JrMX[i] = MAX(vout.JrMX[i-1] + prof.tr.Jr[1],
                           vout.ErMX[i] + prof.tr.Er[0]);
        vout.JrMX[i] = MAX(vout.JfMX[i],
                           vout.EfMX[i] + prof.tr.Ef[1]);
        /* C state */
        vout.CMX[i] = MAX(vout.CMX[i-1] + prof.tr.C[1],
                          vout.EfMX[i] + prof.tr.Ef[2]);
        vout.CMX[i] = MAX(vout.CMX[i], 
                          vout.ErMX[i] + prof.tr.Er[2]);
        /* N state */
        vout.NMX[i] = vout.NMX[i-1] + prof.tr.N[2];

        /* B states */
        vout.BfMX[i] = MAX(vout.NMX[i] + prof.tr.N[0],
                           vout.JfMX[i] + prof.tr.Jf[0]);
        vout.BrMX[i] = MAX(vout.NMX[i] + prof.tr.N[1],
                           vout.JrMX[i] + prof.tr.Jr[0]); 
    
    }
    /* Termination */
    vout.score = vout.CMX[L] + prof.tr.C[0];
    vout.L = L;
    vout.M = M;
    return vout;
};
