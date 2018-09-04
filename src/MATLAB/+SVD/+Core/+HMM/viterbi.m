function [ vitTraceback, score ] = viterbi( p1_profile, sequence )
% P1_VITERBI
%

%% For readability
L   = length(sequence);
M   = p1_profile.len;
tr  = p1_profile.Tr; % Transitions probabilities struct from profile
em  = p1_profile.Em; % Emissions probabilities (Only Mf/Mr)

MfMX    = -inf(L+1, M+1);
MrMX    = -inf(L+1, M+1);

NMX     = -inf(L + 1, 1);
JfMX    = -inf(L + 1, 1);
JrMX    = -inf(L + 1, 1);
CMX     = -inf(L + 1, 1);
BfMX    = -inf(L + 1, 1);
BrMX    = -inf(L + 1, 1);
EfMX    = -inf(L + 1, 1);
ErMX    = -inf(L + 1, 1);

% transition indices. tXY = index of cell containing probability of moving
% from X to Y in the transition matrix.
tNBf    = 1;
tNBr    = 2;
tNN     = 3;

tJB     = 1;
tJJ     = 2;

tCT     = 1;
tCC     = 2;

tEJs    = 1;
tEJo    = 2;
tEC     = 3;

tMM     = 1;
tME     = 2;


%% Viterbi
% initialisation step
NMX(1) = 0;
BfMX(1) = tr.N(tNBf);
BrMX(1) = tr.N(tNBr);
% loop
for i = 2:L+1

    % First match states
    MfMX(i, 2) = max([MfMX(i-1, M+1) + tr.Mf(M+1, tMM), ...
                      BfMX(i-1) + tr.Bf(1)]) + ...
                      em.Mf(2, sequence(i-1));
    MrMX(i, 2) = max([MrMX(i-1, M+1) + tr.Mr(M+1, tMM), ...
                      BrMX(i-1) + tr.Br(1)]) + ...
                      em.Mr(2, sequence(i-1));

    % First E state
    EfMX(i) = max([MfMX(i, 2) + tr.Mf(M+1, tME), ...
                   EfMX(i)]);
    ErMX(i) = max([MrMX(i, 2) + tr.Mr(M+1, tME), ...
                   ErMX(i)]);



    for st = 3:M+1

        MfMX(i, st) = max([MfMX(i-1, st-1) + tr.Mf(st-1, tMM), ...
                           BfMX(i-1) + tr.Bf(st-1)]) + ...
                      em.Mf(st, sequence(i-1));
        MrMX(i, st) = max([MrMX(i-1, st-1) + tr.Mr(st-1, tMM), ...
                           BrMX(i-1) + tr.Br(st-1)]) + ...
                      em.Mr(st, sequence(i-1));
    
        EfMX(i) = max([MfMX(i, st) + tr.Mf(st-1, tME), ...
                           EfMX(i)]);
        ErMX(i) = max([MrMX(i, st) + tr.Mr(st-1, tME), ...
                           ErMX(i)]);
    end

    % J states
    JfMX(i) = max([JfMX(i-1) + tr.Jf(tJJ), ...
                   EfMX(i) + tr.Ef(tEJs), ...
                   ErMX(i) + tr.Er(tEJo)]);
    JrMX(i) = max([JrMX(i-1) + tr.Jr(tJJ), ...
                   ErMX(i) + tr.Er(tEJs), ...
                   EfMX(i) + tr.Ef(tEJo)]);
    % C state
    CMX(i) = max([CMX(i-1) + tr.C(tCC), ...
                  EfMX(i) + tr.Ef(tEC), ...
                  ErMX(i) + tr.Er(tEC)]);
    % N state
    NMX(i) = NMX(i-1) + tr.N(tNN);
    % B states
    BfMX(i) = max([NMX(i) + tr.N(tNBf), ...
                JfMX(i) + tr.Jf(tJB)]);
    BrMX(i) = max([NMX(i) + tr.N(tNBr), ...
                JrMX(i) + tr.Jr(tJB)]);
end

% termination
score = CMX(L+1) + tr.C(tCT);

% Output
p1_viterbi_matrices = struct;
p1_viterbi_matrices.MfMX = MfMX;
p1_viterbi_matrices.MrMX = MrMX;
p1_viterbi_matrices.BfMX = BfMX;
p1_viterbi_matrices.BrMX = BrMX;
p1_viterbi_matrices.EfMX = EfMX;
p1_viterbi_matrices.ErMX = ErMX;
p1_viterbi_matrices.NMX = NMX;
p1_viterbi_matrices.JfMX = JfMX;
p1_viterbi_matrices.JrMX = JrMX;
p1_viterbi_matrices.CMX = CMX;

p1_viterbi_matrices.score = score;
p1_viterbi_matrices.M = M;
p1_viterbi_matrices.L = L;

import SVD.Core.HMM.viterbi_traceback;
vitTraceback = viterbi_traceback(p1_viterbi_matrices, p1_profile, sequence);
