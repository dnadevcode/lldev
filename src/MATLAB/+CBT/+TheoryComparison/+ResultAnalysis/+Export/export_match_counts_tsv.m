function [] = export_match_counts_tsv(tsvFilepath, theoryNames, theoryLengths_bp, matchCounts)
    import Fancy.IO.TSV.write_tsv;
    
    theoryMatchCountsStruct.theoryNames = theoryNames;
    theoryMatchCountsStruct.theoryLengths_bp = theoryLengths_bp;
    theoryMatchCountsStruct.matchCounts = matchCounts;
    write_tsv(tsvFilepath, theoryMatchCountsStruct, fields(theoryMatchCountsStruct));
end