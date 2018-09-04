function [dataTable, originalColHeaders] = get_plasmids_id_report(plasmidsIdReportPath)
    % GET_PLASMIDS_REPORT - Loads the NCBI plasmid genome ID report as a table
    %
    % Inputs:
    %  plasmidsIdReportPath (optional)
    %   the url/path of the report on Plasmids
    %   defaults to the following:
    %    ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/IDS/Plasmids.ids
    %
    % Outputs:
    %  dataTable
    %    the table of data in the report
    %  originalColHeaders
    %    the original column headers for the data (since Matlab's table
    %    only supports unique valid matlab variable names as column
    %    headers in the table and the headers need to be updated to meet 
    %    the validation criteria)
    import NCBI.tsvStr2table;

    if nargin < 1
        plasmidsIdReportPath = 'ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/IDS/Plasmids.ids';
    end
    [tsvStr, successStatus] = urlread(plasmidsIdReportPath);
    if not(successStatus)
        error(['Failed to load plasmids report from ''', plasmidsIdReportPath, '''']);
    end
   [dataTable, originalColHeaders] = tsvStr2table(tsvStr, false);
end

