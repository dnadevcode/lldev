function seqOut = add_some_noise(seqIn, noiseMag)
    seqOut = seqIn + noiseMag*(2*rand(size(seqIn)) - 1);
end