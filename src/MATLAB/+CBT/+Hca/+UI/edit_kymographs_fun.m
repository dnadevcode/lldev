function [ hcaSessionStruct ] = edit_kymographs_fun( hcaSessionStruct,kymoStructs,kymoNames )
    % edit_kymographs_fun 
    % this just puts kymo's in the hca structure
    kymoStructs = cellfun(@(tl) tl.unalignedKymo,kymoStructs,'UniformOutput', false);     
    hcaSessionStruct.unalignedKymos = kymoStructs;
    hcaSessionStruct.names = kymoNames;       
end

