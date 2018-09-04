function [ p1_trace ] = viterbi_traceback( p1_viterbi_matrices, p1_profile, dsequence )
%P1_VITERBI_TRACEBACK
% Finds and reports the most likely state sequence through a viterbi matrix.

%% readability
M = p1_viterbi_matrices.M;
L = p1_viterbi_matrices.L;
MfMX = p1_viterbi_matrices.MfMX;
MrMX = p1_viterbi_matrices.MrMX;
BfMX = p1_viterbi_matrices.BfMX;
BrMX = p1_viterbi_matrices.BrMX;
EfMX = p1_viterbi_matrices.EfMX;
ErMX = p1_viterbi_matrices.ErMX;
JfMX = p1_viterbi_matrices.JfMX;
JrMX = p1_viterbi_matrices.JrMX;
NMX = p1_viterbi_matrices.NMX;
CMX = p1_viterbi_matrices.CMX;
tr = p1_profile.Tr;
em = p1_profile.Em;

% state indices
siS = 1;
siT = 2;
siN = 3;
siC = 4;
siBf = 5;
siBr = 6;
siEf = 7;
siEr = 8;
siJf = 9;
siJr = 10;
siMf = 11;
siMr = 12;

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
%%

%% Traceback
i = L + 1;
st = 1;
p1_trace = [];
prev_st = siC;
crnt_st = 0;

while prev_st ~= siS
    switch prev_st
    case siC
        if CMX(i) == -inf
            error('Impossible value for C state at %d', i);
        end
        if CMX(i) == CMX(i-1) + tr.C(tCC)
            crnt_st = siC;
        elseif CMX(i) == EfMX(i) + tr.Ef(tEC)
            crnt_st = siEf;
        elseif CMX(i) == ErMX(i) + tr.Er(tEC)
            crnt_st = siEr;
        else
            error('Can not traceback from C state at %d', i);
        end
    case siEf
        if EfMX(i) == -inf
            error('Impossible value for E-forward state at %d', i);
        end
        for j = M+1:-1:2
            if EfMX(i) == MfMX(i, j) + tr.Mf(j-1, tME)
                st = j;
                crnt_st = siMf;
            end
        end
    case siEr
        if ErMX(i) == -inf
            error('Impossible value for E-reverse state at %d', i);
        end
        for j = M+1:-1:2
            if ErMX(i) == MrMX(i, j) + tr.Mr(j-1, tME)
                st = j;
                crnt_st = siMr;
            end
        end
    case siMf
        if MfMX(i, st) == -inf
        	error('Impossible value for M state at sequence %d state %d', i, st);
        end
        if MfMX(i, st) == BfMX(i-1) + tr.Bf(st-1) + em.Mf(st, dsequence(i-1))
            crnt_st = siBf;
        elseif MfMX(i, st) == MfMX(i-1, st-1) + tr.Mf(st-1, tMM) + em.Mf(st, dsequence(i-1))
            crnt_st = siMf;
        elseif (st == 2)
            if MfMX(i, 2) == MfMX(i-1, M+1) + tr.Mf(M+1, tMM) + em.Mf(2, dsequence(i-1))
                crnt_st = siMf;
            end
        else
            error('Can not traceback from M at sequence %d state %d', i, st);
        end
        st = st - 1;
        i = i - 1;  
        if (st == 1)
            st = M+1;
        end
        
    case siMr
        if MrMX(i, st) == -inf
        	error('Impossible value for M state at sequence %d state %d', i, st);
        end
        if MrMX(i, st) == BrMX(i-1) + tr.Br(st-1) + em.Mr(st, dsequence(i-1))
            crnt_st = siBr;
        elseif MrMX(i, st) == MrMX(i-1, st-1) + tr.Mr(st-1, tMM) + em.Mr(st, dsequence(i-1))
            crnt_st = siMr;
        elseif (st == 2)
            if MrMX(i, 2) == MrMX(i-1, M+1) + tr.Mr(M+1, tMM) + em.Mr(2, dsequence(i-1))
                crnt_st = siMr;
            end
        else
            error('Can not traceback from M at sequence %d state %d', i, st);
        end
        st = st - 1;
        i = i - 1;  
        if (st == 1)
            st = M+1;
        end
        
    case siN
        if NMX(i) == -inf
            error('Impossible value for N state at %d', i);
        end
        if i <= 1
            crnt_st = siS;
        else
            crnt_st = siN;
        end
        
    case siBf
        if BfMX(i) == -inf
            error('Impossible value for B-forward state at %d', i);
        end
        if BfMX(i) == NMX(i) + tr.N(tNBf)
            crnt_st = siN;
        elseif BfMX(i) == JfMX(i) + tr.Jf(tJB)
            crnt_st = siJf;
        else
            error('Can not traceback from B-forward state at %d', i);
        end
    case siBr
        if BrMX(i) == -inf
            error('Impossible value for B-reverse state at %d', i);
        end
        if BrMX(i) == NMX(i) + tr.N(tNBr)
            crnt_st = siN;
        elseif BrMX(i) == JrMX(i) + tr.Jr(tJB)
            crnt_st = siJr;
        else
            error('Can not traceback from B-reverse state at %d', i);
        end           
    case siJf
        if JfMX(i) == -inf
            error('Impossible value for J-forward state at %d', i);
        end
        if JfMX(i) == JfMX(i-1) + tr.Jf(tJJ)
            crnt_st = siJf;
        elseif JfMX(i) == EfMX(i) + tr.Ef(tEJs)
            crnt_st = siEf;
        elseif JfMX(i) == ErMX(i) + tr.Er(tEJo)
            crnt_st = siEr;
        else
            error('Can not traceback from J-forward at sequence %d', i);
        end
        
    case siJr
        if JrMX(i) == -inf
            error('Impossible value for J-reverse state at %d', i);
        end
        if JrMX(i) == JrMX(i-1) + tr.Jr(tJJ)
            crnt_st = siJr;
        elseif JrMX(i) == ErMX(i) + tr.Er(tEJs)
            crnt_st = siEr;
        elseif JrMX(i) == EfMX(i) + tr.Ef(tEJo)
            crnt_st = siEf;
        else
            error('Can not traceback from J-reverse at sequence %d', i);
        end   
    end

    if (crnt_st == prev_st) && (crnt_st == siN  || crnt_st == siJf || crnt_st == siJr || crnt_st == siC)
        i = i - 1;
        p1_trace(end+1, 1:3) = [i-1, crnt_st, 0];
    end
    if crnt_st == siMf
        p1_trace(end+1, 1:3) = [i-1, crnt_st, st - 1];   
    elseif crnt_st == siMr
        p1_trace(end+1, 1:3) = [i-1, crnt_st, (M - st + 2)];
    end


    prev_st = crnt_st;
end
end

