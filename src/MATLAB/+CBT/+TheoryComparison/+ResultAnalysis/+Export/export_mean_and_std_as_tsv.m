function [] = export_mean_and_std_as_tsv(tsvFilepathMeanAndStd, theoryNames, theoryLengths_bp, meanOfBestCCsIncluded, stdOfBestCCsIncluded)
    import Fancy.IO.TSV.write_tsv;

    sMeanAndStd.theoryNames = theoryNames;
    sMeanAndStd.theoryLengths_bp = theoryLengths_bp;
    sMeanAndStd.meanBestCC = meanOfBestCCsIncluded;
    sMeanAndStd.stdBestCC = stdOfBestCCsIncluded;
    write_tsv(tsvFilepathMeanAndStd, sMeanAndStd, fields(sMeanAndStd));
end