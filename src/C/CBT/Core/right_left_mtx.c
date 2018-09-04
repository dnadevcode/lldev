#if !defined(_WIN32)
#define dgemm dgemm_
#define dnrm2 dnrm2_
#endif

#include "mex.h"
#include "blas.h"

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *bindingConstants, *idxTmp, 
           *normCons, *constraintMat,
           *A, *B, *trans;
    int seqStart, seqEnd, interval, mtimesReverse, numCons;
    int i, j, Aidx, Bidx;
    int *bindingIdxs;
    size_t m,n,p;        
    char *chn = "N";
    double one = 1.0, zero = 0.0;

    mtimesReverse = mxGetScalar(prhs[7]);
    if (mtimesReverse == 1) {
        Aidx = 6;
        Bidx = 5;
    } else {
        Aidx = 5;
        Bidx = 6;
    }
    A = mxGetPr(prhs[Aidx]);
    B = mxGetPr(prhs[Bidx]);
    m = mxGetM(prhs[Aidx]);
    n = mxGetN(prhs[Bidx]);
    p = mxGetN(prhs[Aidx]);
    ptrdiff_t vec = (ptrdiff_t) p;
    ptrdiff_t on2 = 1;
    
    seqStart = mxGetScalar(prhs[0]);
    interval = mxGetScalar(prhs[1]);
    seqEnd = mxGetScalar(prhs[2]); 
    bindingConstants = mxGetPr(prhs[3]);
    idxTmp = mxGetPr(prhs[4]);
    numCons = mxGetM(prhs[4]);
    bindingIdxs = (int *) mxMalloc(sizeof(int)*numCons);
    for(i=0; i<numCons; i++) {
        bindingIdxs[i] = idxTmp[i];
    }

    if ( mtimesReverse == 1 ) {
        plhs[0] = mxCreateDoubleMatrix(1, seqStart, mxREAL);
        plhs[1] = mxCreateDoubleMatrix(p, seqStart, mxREAL);
    
    } else { 
        plhs[0] = mxCreateDoubleMatrix(1, seqEnd, mxREAL);
        plhs[1] = mxCreateDoubleMatrix(p, seqEnd, mxREAL);
    }
    normCons = mxGetPr(plhs[0]);
    constraintMat = mxGetPr(plhs[1]);

    if ( mtimesReverse == 1) {
        for (i=seqStart-1; i>=seqEnd-1; i=i+interval) {
            for (j=0; j<numCons; j++) {
                A[bindingIdxs[j]-1] = bindingConstants[(2*i)+j];
            }
            double * mtxPtr = &constraintMat[i*p];
            dgemm(chn, chn, &m, &n, &p, &one, A, &m, B, &p, &zero, mtxPtr, &m);
            normCons[i] = dnrm2(&vec, mtxPtr, &on2);
            for (j=0;j<p;j++) {
                mtxPtr[j] = mtxPtr[j]/normCons[i];
            }
            B = &constraintMat[i*p];
        }
    } else {
        for (i=seqStart-1; i<seqEnd; i=i+interval) {
            for (j=0; j<numCons; j++) {
                B[bindingIdxs[j]-1] = bindingConstants[(2*i)+j];
            }
            double * mtxPtr = &constraintMat[i*p];
            dgemm(chn, chn, &m, &n, &p, &one, A, &m, B, &p, &zero, mtxPtr, &m);
            normCons[i] = dnrm2(&vec, mtxPtr, &on2);
            for (j=0;j<p;j++) {
                mtxPtr[j] = mtxPtr[j]/normCons[i];
            }
            A = &constraintMat[i*p];
        }
    }
    

    return;
}
