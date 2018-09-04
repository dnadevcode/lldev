function [sValsHistMat] = calc_tree_method_svals_mat(croppedContigBarcodes, contigOrderingsMat, startMat, sValsByBranch, coverageByBranch)
    %---Visualize the Tree---
    startMatTemp = startMat;
    sValsHistMat = ones(4,length(sValsByBranch));
    % 1. Number of branches
    % 2. Lowest index of the equal branches
    % 3. Highest s-value for the branches
    % 4. Coverage of the branches
    idxHist = 1;
    numCon = zeros(1,2);
    while idxHist < length(sValsByBranch) + 1
        if sum(startMatTemp(idxHist,:) == 0) == length(croppedContigBarcodes)
            idxHist = idxHist + 1;
            continue
        end
        sValsHistMat(2,idxHist) = idxHist;
        sValsHistMat(3,idxHist) = sValsByBranch(idxHist);
        sValsHistMat(4,idxHist) = coverageByBranch(idxHist);
        tempVec1 = sortrows([contigOrderingsMat(idxHist,:)' startMat(idxHist,:)']);
        numCon(1) = sum(contigOrderingsMat(idxHist,:) ~= 0);
        for jHist = idxHist+1:size(startMatTemp,1)
            numCon(2) = sum(contigOrderingsMat(jHist,:) ~= 0);
            if numCon(1) == numCon(2)
                tempVec2 = sortrows([contigOrderingsMat(jHist,:)' startMat(jHist,:)']);
                if sum(tempVec1(end-numCon(1)+1:end,2)==tempVec2(end-numCon(1)+1:end,2))== numCon(1)
                    if sValsByBranch(jHist) > sValsByBranch(idxHist)
                        sValsHistMat(3,idxHist) = sValsByBranch(jHist);
                    end
                    sValsHistMat(1,idxHist) = sValsHistMat(1,idxHist) + 1;
                    startMatTemp(jHist,:) = 0;
                end
            end
        end
        idxHist = idxHist + 1;
    end
    sValsHistMat(:,sValsHistMat(3,:)==1) = [];
end