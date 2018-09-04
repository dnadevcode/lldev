#include<stdlib.h>
#include"p1_viterbi_matrices.h"

struct p1_viterbi_matrices p1_gen_vmtx(int proflen, int seqlen) {
    struct p1_viterbi_matrices vmtx;
    vmtx.MfMX = (double *) malloc((seqlen+1)*(proflen+1)*sizeof(double));
    vmtx.MrMX = (double *) malloc((seqlen+1)*(proflen+1)*sizeof(double));
    vmtx.BfMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.BrMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.EfMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.ErMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.JfMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.JrMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.NMX = (double *) malloc((seqlen+1)*sizeof(double));
    vmtx.CMX = (double *) malloc((seqlen+1)*sizeof(double));
    return vmtx;
}


void p1_free_vmtx(struct p1_viterbi_matrices vmtx) {
    free(vmtx.MfMX);
    free(vmtx.MrMX);
    free(vmtx.BfMX);
    free(vmtx.BrMX);
    free(vmtx.EfMX);
    free(vmtx.ErMX);
    free(vmtx.JfMX);
    free(vmtx.JrMX);
    free(vmtx.NMX);
    free(vmtx.CMX);
}
