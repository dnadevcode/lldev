#if !defined(_WIN32)
/*#define dgemm dgemm_*/
#define dgemv dgemv_
#define ddot ddot_
#endif

#include "mex.h"
#include "blas.h"

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

    int numBasepairs, bindingIdx, i, j, k;
    double *seqBindingConstants, *transferMatrix, 
           *firstVec, *lastVec, 
           *rightMatrix, *leftMatrix,
           *bindingProbs, *tmpVec;

    size_t m, n1, n2, p;        
    char *chn = "N";
    double one = 1.0, zero = 0.0;
    ptrdiff_t inc1 = 1, naught = 0;

    numBasepairs = (int) mxGetScalar(prhs[0]);
    seqBindingConstants = mxGetPr(prhs[1]);
    bindingIdx = (int) mxGetScalar(prhs[2]);
    transferMatrix = mxGetPr(prhs[3]);
    firstVec = mxGetPr(prhs[4]);
    lastVec = mxGetPr(prhs[5]);
    rightMatrix = mxGetPr(prhs[6]);
    leftMatrix = mxGetPr(prhs[7]);
    m = mxGetM(prhs[4]);
    p = mxGetN(prhs[4]);
    n1 = mxGetN(prhs[3]);
    n2 = 1; /* mxGetM(prhs[6]);*/
    tmpVec = mxMalloc(sizeof(double) * n1);

    plhs[0] = mxCreateDoubleMatrix(1, numBasepairs, mxREAL);
    bindingProbs = mxGetPr(plhs[0]);

    transferMatrix[bindingIdx-1] = seqBindingConstants[0];
    double * rmPtr = &rightMatrix[9];
    dgemm(chn, chn, &m, &n1, &p, &one, firstVec, &m, transferMatrix, &p, &zero, tmpVec, &m);
    bindingProbs[0] = ddot(&n1, tmpVec, &inc1, rmPtr, &inc1);
    
    for(i=1;i<numBasepairs-1;i++) {
        double * lmPtr = &leftMatrix[(i-1)*9];
        double * rmPtr = &rightMatrix[(i+1)*9];
        double * bpPtr = &bindingProbs[i];
        transferMatrix[bindingIdx-1] = seqBindingConstants[i];
        dgemm(chn, chn, &m, &n1, &p, &one, lmPtr, &m, transferMatrix, &p, &zero, tmpVec, &m);
        bindingProbs[i] = ddot(&n1, tmpVec, &inc1, rmPtr, &inc1);
    }

    double * lmPtr = &leftMatrix[(numBasepairs-1)*9];
    double * bpPtr = &bindingProbs[numBasepairs];
    transferMatrix[bindingIdx-1] = seqBindingConstants[numBasepairs];
    dgemm(chn, chn, &m, &n1, &p, &one, lmPtr, &m, transferMatrix, &p, &zero, tmpVec, &m);
    bindingProbs[numBasepairs] = ddot(&n1, tmpVec, &inc1, rmPtr, &inc1);
    
}
