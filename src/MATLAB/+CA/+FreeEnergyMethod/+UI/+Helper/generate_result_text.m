function resultTextStr = generate_result_text(sValsByBranch, numTotalOverlapsByBranch)
    numOverTotPrint = num2str(numTotalOverlapsByBranch(sValsByBranch(:,2)));

    % Format the text to be printed on result window
    sTotNums = (round(sValsByBranch(:,1)*10000));
    % sTotNums(sTotNums/10 == floor(sTotNums/10)) = sTotNums(sTotNums/10 == floor(sTotNums/10))+1;
    sTotPrint = num2str(sTotNums/10000);

    tabStr = '    ';
    header = ['Index:' tabStr 'S-value:' tabStr 'overlap:'];

    resultTextStr = char(zeros(size(sValsByBranch,1)+1,length(header)));
    resultTextStr(1,:) = header;
    for resultIdx = 1:size(sValsByBranch,1)
        % Must be same number of characters on each row
        if resultIdx < 10
            resSpace1 = '     ';
        else
            resSpace1 = '    ';
        end
        resSpace2 = char(zeros(1,8-length(sTotPrint(resultIdx,:))));
        for iSpace = 1:length(resSpace2)
            resSpace2(iSpace) = ' ';
        end
        resSpace3 = char(zeros(1,8-length(numOverTotPrint(resultIdx,:))));
        for iSpace = 1:length(resSpace3)
            resSpace3(iSpace) = ' ';
        end
        resultTextStr(resultIdx+1,:) = [num2str(resultIdx) resSpace1 tabStr sTotPrint(resultIdx,:) resSpace2 tabStr num2str(numOverTotPrint(resultIdx,:)) resSpace3];
    end
end
