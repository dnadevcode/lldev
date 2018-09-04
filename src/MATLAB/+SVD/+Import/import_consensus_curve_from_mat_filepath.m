function [consensusCurve] = import_consensus_curve_from_mat_filepath(matFilepath)
    consensusObj = matfile(matFilepath);
    consensusData = consensusObj.clusterConsensusData;
    consensusCurve = consensusData.barcode;
    consensusCurve = consensusCurve(:);
end