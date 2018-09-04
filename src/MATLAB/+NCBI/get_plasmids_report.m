function [dataTable, originalColHeaders] = get_plasmids_report(plasmidsReportPath)
    % GET_PLASMIDS_REPORT - Loads the NCBI plasmid genome report as a table
    %
    % Inputs:
    %  plasmidsReportPath (optional)
    %   the path/url of the report on Plasmids
    %   defaults to the following:
    %    ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/plasmids.txt
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
        plasmidsReportPath = 'ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/plasmids.txt';
    end
    [tsvStr, successStatus] = urlread(plasmidsReportPath);
    if not(successStatus)
        error(['Failed to load plasmids report from ''', plasmidsReportPath, '''']);
    end
   [dataTable, originalColHeaders] = tsvStr2table(tsvStr, true);
end