function [ hcaSessionStruct ] = combine_chromosome_results( hcaSessionStruct,sets )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%     hcaSessionStruct.comparedStructure
%     cellfun(@(x) 
%     	maxcoef = cell2mat(cellfun(@(x) x.maxcoef,hcaSessionStruct.comparedStructure{1},'UniformOutput',0));

    indx = zeros(1,length(hcaSessionStruct.comparedStructure{1}));
    hcaSessionStruct.comparisonStructure = cell(length(hcaSessionStruct.comparedStructure{1}),1);
    
    accuLengths = cellfun(@length,hcaSessionStruct.theoryGen.theoryBarcodes);

    for i=1:length(hcaSessionStruct.comparedStructure{1})
        structTemp = (cellfun(@(x) x{i},hcaSessionStruct.comparedStructure));
        maxCoefs = arrayfun(@(x) x.maxcoef(1),structTemp);
        [~,indx(i)] = max(maxCoefs);
        hcaSessionStruct.comparisonStructure{i} = hcaSessionStruct.comparedStructure{indx(i)}{i};
        hcaSessionStruct.comparisonStructure{i}.idx = indx(i);
        hcaSessionStruct.comparisonStructure{i}.pos =  hcaSessionStruct.comparisonStructure{i}.pos+sum(accuLengths(1:indx(i)-1));
        hcaSessionStruct.comparisonStructure{i}.name = hcaSessionStruct.theoryGen.theoryNames{indx(i)};
    end
        % we want to define hcaSessionStruct.comparisonStructure from hcaSessionStruct.comparedStructure
   
    if sets.filterSettings.filter==1
        indx = zeros(1,length(hcaSessionStruct.comparedStructureFiltered{1}));
        hcaSessionStruct.comparisonStructureFiltered = cell(length(hcaSessionStruct.comparedStructureFiltered{1}),1);

        accuLengths = cellfun(@length,hcaSessionStruct.theoryGen.theoryBarcodes);

        for i=1:length(hcaSessionStruct.comparedStructure{1})
            structTemp = (cellfun(@(x) x{i},hcaSessionStruct.comparedStructureFiltered));
            maxCoefs = arrayfun(@(x) x.maxcoef(1),structTemp);
            [~,indx(i)] = max(maxCoefs);
            hcaSessionStruct.comparisonStructureFiltered{i} = hcaSessionStruct.comparedStructureFiltered{indx(i)}{i};
            hcaSessionStruct.comparisonStructureFiltered{i}.pos =  hcaSessionStruct.comparisonStructureFiltered{i}.pos+sum(accuLengths(1:indx(i)-1));
            hcaSessionStruct.comparisonStructureFiltered{i}.name = hcaSessionStruct.theoryGen.theoryNames{indx(i)};
        end
    end

end

