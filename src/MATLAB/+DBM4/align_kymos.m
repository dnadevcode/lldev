function [kymoStructs, badMasks] = align_kymos(kymoStructs, sets, names)
    % align kymos
    %
    %   Args:
    %       kymoStructs
    %       sets
    %
    %   Returns:
    %       kymoStructs - aligned kymoStructs
    %       badMasks - which kymographs where remove due to bad masks

    % align using spalign, only takes kymo pixels from first feature to the
    % last as barcode, so might miss part of barcode if features are not
    % visible
    import OptMap.KymoAlignment.SPAlign.spalign;
    import OptMap.KymoAlignment.PersistenceAlign.peralign;

    % kymoStructs = cell(1,length(filtKymo));
    badMasks = [];
    for i=1:length(kymoStructs)
    %     i

%            try % some alignment method
%         [kymoStructs{i}.alignedKymo,kymoStructs{i}.alignedMask,~,~,newMask,f] = ...
%         peralign(double(kymoStructs{i}.unalignedKymo),kymoStructs{i}.unalignedBitmask,sets.minOverlap,sets.maxShift,sets.skipPreAlign, sets.detPeaks);
%         if (sum(kymoStructs{i}.alignedMask(:))==0)
%             kymoStructs{i}.alignedMask = kymoStructs{i}.unalignedBitmask; % there was a single feature
%         end

        try % some alignment method
        [kymoStructs{i}.alignedKymo,kymoStructs{i}.alignedMask,~,~,newMask] = ...
        spalign(double(kymoStructs{i}.unalignedKymo),kymoStructs{i}.unalignedBitmask,sets.minOverlap,sets.maxShift,sets.skipPreAlign, sets.detPeaks);
        if (sum(kymoStructs{i}.alignedMask(:))==0)
            kymoStructs{i}.alignedMask = kymoStructs{i}.unalignedBitmask; % there was a single feature
        end
% %         % temp hack to get longer barcode:
% %         kymoStructs{i}.alignedMask = zeros(size(kymoStructs{i}.alignedKymo));
% %         numNans = sum(isnan(kymoStructs{i}.alignedKymo));
% %         stPt = find(numNans==0,1,'first');     stopPt = find(numNans==0,1,'last');
% %         if isempty(stPt)
% %             stPt = 1;
% %         end
% %        if isempty(stopPt)
% %             stPt = length(numNans);
% %         end
% %          
% %         kymoStructs{i}.alignedMask(:,stPt:stopPt) =  1;
% %         
        kymoStructs{i}.leftEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'first'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.rightEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'last'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.name = names{i};
        kymoStructs{i}.len = sum(newMask');
        kymoStructs{i}.lenParams = polyfit(1:length(kymoStructs{i}.len ),kymoStructs{i}.len ,1);
        catch
            badMasks = [badMasks i];
        end
    end
    kymoStructs(badMasks) = []; % remove kymos with bad masks

end

