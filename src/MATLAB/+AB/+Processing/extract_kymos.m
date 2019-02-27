function [flattenedKymos, layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movieArr, rRot, cRot, kymoMolEdgeIdxs,avgL)
    % extract_kymos

    % :param movieArr: original movie
    % :param kep : kymo edge point coordinates
    %
    % :returns: layeredKymos, kymosMasks, kymosCenterXYCoords

    % rewritten by Albertas Dvirnas

    fprintf('Extracting kymos...\n');
    
    % number of kymographs
    nK = length(kymoMolEdgeIdxs);
   
    % initialization of kymos, masks, center coords, center offsets
    layeredKymos = cell(nK, 1);
    kymosMasks = cell(nK, 1);
    
    % try to get this much of pixels to the left and the right of kymograph
    sideDist = 50;
      
    flattenedKymos = cell(nK, 1);
       
    kymoCols = -avgL:avgL;
   
    numFrames = size(movieArr,3);
    
    kymosCenterXYCoords = cell(nK,1);
    
    % now go through kymographs
    for kymoNum = 1:nK
        % current column
        meanCol = mean(mean(kymoMolEdgeIdxs{kymoNum}(:,2,:)));
        
        % minimum row
        minRow = max(3,min(kymoMolEdgeIdxs{kymoNum}(:,1,1))-sideDist);
        % maximum row
        maxRow = min(size(rRot,1)-2,max(kymoMolEdgeIdxs{kymoNum}(:,1,2))+sideDist);
        
        coordsRow = (minRow:maxRow);
        
        % compute the bitmask, this might shift a little left or right from
        % frame to frame
        
        % for each frame, transform left and right edges based on minRow

        bitRow = zeros(numFrames,maxRow-minRow+1);
        rowIdx = zeros(numFrames,2);
        for j=1:numFrames
           rowIdx(j,:) =  kymoMolEdgeIdxs{kymoNum}(j,1,:)-minRow+1;
           bitRow(j,rowIdx(j,1):min(size(bitRow,2),rowIdx(j,2))) = 1;
           
           xyC = round([mean(kymoMolEdgeIdxs{kymoNum}(j,1,:)),mean(kymoMolEdgeIdxs{kymoNum}(j,2,:))]);
           
           % have to still convert these
           kymosCenterXYCoords{kymoNum}(j,:) = fliplr([rRot(xyC(1),xyC(2)),cRot(xyC(1),xyC(2))]);

        end
        kymosMasks{kymoNum}=bitRow;
        
        % this saved layered kymos
        layeredKymos{kymoNum} = nan(numFrames, length(minRow:maxRow),length(kymoCols));
        
        % go through snapshots of the molecule in the direction
        for j=1:length(kymoCols)
            curCol = meanCol +kymoCols(j);
            coords = [coordsRow', repmat(curCol,maxRow-minRow+1,1)];
            for i =1:size(coords,1)
                coords(i,:) = [rRot(coords(i,1), coords(i,2)), cRot(coords(i,1), coords(i,2))];
            end
            % go through the number of frames
            for fN=1:numFrames
                for t=1:size(coords,1)
                    try
                        layeredKymos{kymoNum}(fN,t,j) = movieArr(coords(t,1),coords(t,2),fN);
                    catch
                        layeredKymos{kymoNum}(fN,t,j) = nan;
                    end
                end    
         
            end
            
        end
        
        % compute the nanmean of the layered kymographs
        flattenedKymos{kymoNum} = nanmean(layeredKymos{kymoNum},3);  
    end
            
    fprintf('Extracted kymos\n');

end