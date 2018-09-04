#ifndef VITERBI_MATRICES_HEADER
#define VITERBI_MATRICES_HEADER
/*  Plan 1 HMM viterbi matrices. Structure to be outputted by p1_viterbi function.
 *  Contains the following fields:
 *  * MfMX  - Match states (forward direction) matrix (MxL)
 *  * MrMX  - Match states (backward direciton) matrix (MxL)
 *  * NMX   - N-terminal repeat state matrix (1xL)
 *  * JfMX  - Joining state (forward) matrix (1xL)
 *  * JrMX  - Joining state (backward) matrix (1xL)
 *  * CMX   - C-terminal repeat state (1xL)
 *  * BfMX  - Begin-state (forward) matrix (1xL)
 *  * BrMX  - Begin-state (backward) matrix (1xL)
 *  * EfMX  - End-state (forward) matrix (1xL)
 *  * ErMX  - End-state (backward) matrix (1xL)
 *  * score - log-odds score of best viterbi path
 *  * M     - Number of match states (length of profile).
 *  * L     - Length of input sequence
 *
 */

typedef struct p1_viterbi_matrices {
    int M, L;
    double score;
    double *MfMX, *MrMX, *NMX, *JfMX, *JrMX;
    double *CMX, *BfMX, *BrMX, *EfMX, *ErMX;
} p1_viterbi_matrices;

struct p1_viterbi_matrices p1_gen_vmtx(int proflen, int seqlen);
void p1_free_vmtx(struct p1_viterbi_matrices vmtx);

#endif
