function [curve] = import_curve_from_filepath(filepath)
    curve = [];
    [~, ~, fileExt] = fileparts(filepath);
    %Compute theory sequence if filetype is .fasta or .txt:
    if strcmp(fileExt, '.fasta')
        import SVD.Import.import_zscaled_theory_curve_from_seq_filepath;
        curve = import_zscaled_theory_curve_from_seq_filepath(filepath);
    elseif strcmp(fileExt, '.mat')
        import SVD.Import.import_consensus_curve_from_mat_filepath;
        curve = import_consensus_curve_from_mat_filepath(filepath);
    end
end