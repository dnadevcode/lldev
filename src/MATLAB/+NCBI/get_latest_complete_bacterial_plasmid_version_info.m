function [refSeqs, refSeqsAccessionNumber, refSeqsAccessionVersionNumber, plasmidsDataTable, originalColHeaders] = get_latest_complete_bacterial_plasmid_version_info()
    [plasmidsDataTable, originalColHeaders] = NCBI.get_plasmids_report();
    isBacterialPlasmid = ismember(plasmidsDataTable{:,'Kingdom'}, {'Bacteria'});
    dataTableBacterialPlasmids = plasmidsDataTable(isBacterialPlasmid,:);
    refSeqs = setdiff(unique(dataTableBacterialPlasmids{:, 'RefSeq'}), {'-'});
    fn_starts_with = @(str1, str2) strcmp(str1(1:min(end,length(str2))), str2);
    % http://www.ncbi.nlm.nih.gov/books/NBK21091
    % NC_ accession prefix for 	Complete genomic molecules
    tmpFilter = cellfun(@(str) (fn_starts_with(str, 'NC_') && (length(strfind(str,'.')) == 1)), refSeqs);
    refSeqs = refSeqs(tmpFilter);
    refSeqsAccessionNumber = cellfun(@(refSeq) uint64(str2double(refSeq(4:(strfind(refSeq,'.') - 1)))), refSeqs);
    refSeqsAccessionVersionNumber = cellfun(@(refSeq) uint64(str2double(refSeq((strfind(refSeq,'.') + 1):end))), refSeqs);
    tmpFilter = not(isnan(refSeqsAccessionNumber))...
        & not(isnan(refSeqsAccessionVersionNumber))...
        & arrayfun(@(an, avn) (avn == max(refSeqsAccessionVersionNumber(refSeqsAccessionNumber == an))), refSeqsAccessionNumber, refSeqsAccessionVersionNumber);
    refSeqsAccessionNumber = refSeqsAccessionNumber(tmpFilter);
    refSeqsAccessionVersionNumber = refSeqsAccessionVersionNumber(tmpFilter);
    refSeqs = refSeqs(tmpFilter);
end