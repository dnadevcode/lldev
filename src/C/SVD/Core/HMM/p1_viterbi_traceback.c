#include"p1_viterbi_traceback.h"
#include"math.h"
#include"stdbool.h"
#define siS 1
#define siT 2
#define siN 3
#define siC 4
#define siBf 5
#define siBr 6
#define siEf 7
#define siEr 8
#define siJf 9
#define siJr 10
#define siMf 11
#define siMr 12


bool fEq(double a, double b)
{
    return fabs(a-b) < 0.00001;
}

void p1_viterbi_traceback(struct p1_viterbi_matrices mtx, struct p1_profile prof, int dsequence[], int vtrace[]) {

    int i, st, j, L, M, crnt_st, prev_st, tracepos;
    
    M = prof.length;
    L = dsequence[0];

    i = L;
    st = 0;
    prev_st = siC;
    crnt_st = 0;
    tracepos = 0;

    while(prev_st != siS) {
        switch(prev_st) {
        case siC:
            if (mtx.CMX[i] == -INFINITY) {
                printf("Impossible value for C state at %d", i);
                break;
            }
            if (fEq(mtx.CMX[i], mtx.CMX[i-1] + prof.tr.C[1])) {
                crnt_st = siC;
            }
            else if (fEq(mtx.CMX[i], mtx.EfMX[i] + prof.tr.Ef[2])) {
                crnt_st = siEf;
            }
            else if (fEq(mtx.CMX[i], mtx.ErMX[i] + prof.tr.Er[2])) {
                crnt_st = siEr;
            }
            else {
                printf("Can't traceback from C state at %d", i);
                break;
            }
            break;
        case siEf:
            if (mtx.EfMX[i] == -INFINITY) {
                printf("Impossible value for Ef state at %d", i);
                break;
            }
            for(j=M;j>0;j--) {
                if (fEq(mtx.EfMX[i], mtx.MfMX[i*(M+1) + j] + prof.tr.Mf[j+M])) {
                    st = j;
                    crnt_st = siMf;
                    break;
                }
            }
            break;
        case siEr:
            if (mtx.ErMX[i] == -INFINITY) {
                printf("Impossible value for Er state at %d", i);
                break;
            }
            for(j=M;j>0;j--) {
                if (fEq(mtx.ErMX[i], mtx.MrMX[i*(M+1) + j] + prof.tr.Mr[j+M])){
                    st = j;
                    crnt_st = siMr;
                }
            }
            break;
        case siMf:
            if (mtx.MfMX[i*(M+1) + st] == -INFINITY) {
                printf("Impossible value for Mf at seq %d, st %d\n", i, st);
                break;
            }
            if (fEq(mtx.MfMX[i*(M+1) + st], mtx.BfMX[i-1] + prof.tr.Bf[st-1] +\
                                          prof.em.Mf[st +\
                                          ((dsequence[i]-1)*(M+1))])) {
                crnt_st = siBf;
                st--;
                i--;
                break;
            }
            else if (fEq(mtx.MfMX[i*(M+1) + st], mtx.MfMX[(i-1)*(M+1) + st-1] +\
                                               prof.tr.Mf[st-1] +\
                                               prof.em.Mf[st + ((dsequence[i]-1)*(M+1))])) {
                crnt_st = siMf;
                st--;
                i--;
                break;
            }
            else if (st == 1) {
                if (fEq(mtx.MfMX[i*(M+1) + st], mtx.MfMX[(i-1)*(M+1) + M] +\
                                              prof.tr.Mf[M] +\
                                              prof.em.Mf[1 + ((dsequence[i]-1)*(M+1))])) {
                    crnt_st = siMf;
                    st = M;
                    i--;
                    break;
                }
                else {
                    printf("Can't traceback from Mf at seq %d, st %d\n", i, st);
                    break;
                }

            }
                
            else {
                printf("Can't traceback from Mf at seq %d, st %d\n", i, st);
                break;
            }

        case siMr:
            if (mtx.MrMX[i*(M+1) + st] == -INFINITY) {
                printf("Impossible value for Mr at seq %d, st %d\n", i, st);
            } 
            if (fEq(mtx.MrMX[i*(M+1) + st], mtx.BrMX[i-1] + prof.tr.Br[st-1] +\
                                          prof.em.Mr[st +\
                                          ((dsequence[i]-1)*(M+1))])) {
                crnt_st = siBr;
                st--;
                i--;
                break;
            }
            else if (fEq(mtx.MrMX[i*(M+1) + st], mtx.MrMX[(i-1)*(M+1) + st-1] +\
                                               prof.tr.Mr[st-1] +\
                                               prof.em.Mr[st + ((dsequence[i]-1)*(M+1))])) {
                crnt_st = siMr;
                st--;
                i--;
                break;
            }
            else if (st == 1) {
                if (fEq(mtx.MrMX[i*(M+1) + 1],  mtx.MrMX[(i-1)*(M+1) + M] +\
                                                prof.tr.Mr[M] +\
                                                prof.em.Mr[1 + ((dsequence[i]-1)*(M+1))])) {
                    crnt_st = siMr;
                    st = M;
                    i--;
                    break;
                }
                else {
                    printf("Can't traceback from Mr at seq %d, st %d\n", i, st);
                }
            }
            else {
                printf("Can't traceback from Mr at seq %d, st %d\n", i, st);
                break;
            }
            break;
        case siN:
            if (mtx.NMX[i] == -INFINITY) {
                printf("-inf for N state at %d\n", i);
            }
            if (i <= 1) {
                crnt_st = siS;
                break;
            }
            else {
                crnt_st = siN;
            }
            break;
        case siBf:
            if (mtx.BfMX[i] == -INFINITY) {
                printf("-inf at BfMX[%d]\n", i);
                break;
            }
            if (fEq(mtx.BfMX[i], mtx.NMX[i] + prof.tr.N[0])) {
                crnt_st = siN;
            }
            else if (fEq(mtx.BfMX[i], mtx.JfMX[i] + prof.tr.Jf[0])) {
                crnt_st = siJf;
            }
            else {
                printf("Can't traceback from BfMX[%d]\n", i);
            }
            break;
        case siBr:
            if (mtx.BrMX[i] == -INFINITY) {
                printf("-inf at BrMX[%d]\n", i);
                break;
            }
            if (fEq(mtx.BrMX[i], mtx.NMX[i] + prof.tr.N[0])) {
                crnt_st = siN;
            }
            else if (fEq(mtx.BrMX[i], mtx.JrMX[i] + prof.tr.Jr[0])) {
                crnt_st = siJr;
            }
            else {
                printf("Can't traceback from BrMX[%d]\n", i);
            }
            break;
        case siJf:
            if (mtx.JfMX[i] == -INFINITY) {
                printf("-inf at JfMX[%d]\n", i);
            }
            if (fEq(mtx.JfMX[i], mtx.JfMX[i-1] + prof.tr.Jf[1])) {
                crnt_st = siJf;
            }
            else if (fEq(mtx.JfMX[i], mtx.EfMX[i] + prof.tr.Ef[0])) {
                crnt_st = siEf;
            }
            else if (fEq(mtx.JfMX[i], mtx.ErMX[i] + prof.tr.Er[1])) {
                crnt_st = siEr;
            }
            else {
                printf("Can't traceback from JfMX[%d]\n", i);
            }
            break;
        case siJr:
            if (mtx.JrMX[i] == -INFINITY) {
                printf("-inf at JrMX[%d]\n", i);
            }
            if (fEq(mtx.JrMX[i], mtx.JrMX[i-1] + prof.tr.Jr[1])) {
                crnt_st = siJr;
            }
            else if (fEq(mtx.JrMX[i], mtx.ErMX[i] + prof.tr.Er[0])) {
                crnt_st = siEr;
            }
            else if (fEq(mtx.JfMX[i], mtx.EfMX[i] + prof.tr.Ef[1])) {
                crnt_st = siEf;
            }
            else {
                printf("Can't traceback from JfMX[%d]\n", i);
            }
            break;
        }
        if (st == 0) {
            st = M;
        }
        if (crnt_st == siMf) {
            vtrace[tracepos] = i;
            vtrace[tracepos+L] = crnt_st;
            vtrace[tracepos+L+L] = st;
            tracepos++;
        }
        else if (crnt_st == siMr) {
            vtrace[tracepos] = i;
            vtrace[tracepos+L] = crnt_st;
            vtrace[tracepos+L+L] = M - st + 1;
            tracepos++;
        }
        else if ((crnt_st == prev_st) && (crnt_st == siN || crnt_st == siJf || crnt_st == siJr || crnt_st == siC)) {
            vtrace[tracepos] = i;
            vtrace[tracepos+L] = crnt_st;
            vtrace[tracepos+L+L] = 0;
            tracepos++;
            i--;
        }
        prev_st = crnt_st;
        if (tracepos > L) {
            printf("Warning: traceposition increased higher than it should (%d > %d)", tracepos, L);
            crnt_st = siS;
            break;
        }
    }
}
