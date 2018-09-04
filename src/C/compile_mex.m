%   This script will use the Matlab mex command to compile
%   some c/mex functions as alternatives for certain existing
%   matlab functions where a appreciable speed difference
%   can be achieved.
%   The only library required is the matlab BLAS library, which
%   comes with matlab.
%   Compatible C compilers can be found at https://www.mathworks.com/support/compilers.html
%   Windows:
%       Install MinGW (http://tdm-gcc.tdragon.net/)
%       Make sure it is included on PATH / setenv('MW_MINGW64_LOC', pathToGccInstallDir)
%   OS X:
%       Install XCode 7/8 from the Mac App store
%       There is a bug in older MATLABs where it does not detect new XCode
%       versions. A fix is given in:
%       https://se.mathworks.com/matlabcentral/answers/303369-mex-cannot-find-a-supported-compiler-in-matlab-r2015b-after-i-upgraded-to-xcode-8-0#comment_434342
%       or you can update MATLAB.
%   Linux:
%       Install GCC

appDirpath = strsplit(pwd(), filesep);
appDirpath = fullfile(appDirpath{1:end-2});

% CBT
% binding probs mtx
libs = {'-lmwblas'};
c_files = {'CBT/Core/binding_probs_mtx.c'};
out = {'../../bin/+CBT/+Core/binding_probs_mtx'};
try
    outdir = strsplit(out{1}, filesep);
    outdir = fullfile(outdir{1:end-1});
    mkdir(outdir);
    mex(libs{:}, c_files{:}, '-output', out{:});
    disp('CBT.Core.binding_probs_mtx compiled');
catch MExc
    warning(['CBT.Core.binding_probs_mtx failed to compile' char(10) ...
             MExc.getReport]);
end

% right_left_mtx
libs = {'-lmwblas'};
c_files = {'CBT/Core/right_left_mtx.c'};
out = {'../../bin/+CBT/+Core/right_left_mtx'};
try
    outdir = strsplit(out{1}, filesep);
    outdir = fullfile(outdir{1:end-1});
    mkdir(outdir);
    mex(libs{:}, c_files{:}, '-output', out{:});
    disp('CBT.Core.right_left_mtx compiled');
catch MExc
    warning(['CBT.Core.right_left_mtx failed to compile' char(10) ...
             MExc.getReport]);
end

% SVD
% HMM
libs = {};
c_files = {'SVD/Core/HMM/p1_viterbi_mex.c', ...
           'SVD/Core/HMM/p1_viterbi.c', ...
           'SVD/Core/HMM/p1_viterbi_matrices.c', ...
           'SVD/Core/HMM/p1_viterbi_traceback.c'};
out = {'../../bin/+SVD/+Core/+HMM/viterbi'};
try
    outdir = strsplit(out{1}, filesep);
    outdir = fullfile(outdir{1:end-1});
    mkdir(outdir);
    mex(libs{:}, c_files{:}, '-output', out{:});
    disp('SVD.Core.HMM.viterbi compiled');
catch MExc
    warning(['SVD.Core.HMM.viterbi failed to compile' char(10) ...
             MExc.getReport]);
end
