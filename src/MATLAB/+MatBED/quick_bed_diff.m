function [chromStartsOnlyA, chromEndsOnlyA, chromStartsOnlyB, chromEndsOnlyB] = quick_bed_diff()%chromStartsA, chromEndsA, chromStartsB, chromEndsB
	import BlockUtils.get_block_diffs;
%     
%     validateattributes(chromStartsA, {'numeric'}, {'increasing'});
%     validateattributes(chromStartsB, {'numeric'}, {'increasing'});
    

    [filesHasError, fileContents] = MatBED.read_basic_BED();
    if any(filesHasError)
        error('There was a problem reading the files');
    end
    if length(fileContents) ~= 2
        error('Two files must be read for diffing');
    end
    bodyDataA = fileContents{1,'bodyData'}{1};
    bodyDataB = fileContents{2,'bodyData'}{1};
    chromA = bodyDataA{:, 'chrom'};
    chromB = bodyDataB{:, 'chrom'};
    uniqChroms = unique([chromA(:), chromB(:)]);
    numUniqChroms = length(uniqChroms);
    bodyDataCellsOnlyA = cell(numUniqChroms, 1);
    bodyDataCellsOnlyB = cell(numUniqChroms, 1);
    for uniqChromNum = 1:numUniqChroms
        uniqChrom = uniqChroms{uniqChromNum};
        maskA = strcmp(chromA, uniqChrom);
        maskB = strcmp(chromB, uniqChrom);

        chromStartsA = bodyDataA{maskA, 'chromStarts'};
        chromStartsB = bodyDataB{maskB, 'chromStarts'};
        chromEndsA = bodyDataA{maskA, 'chromEnds'};
        chromEndsB = bodyDataB{maskB, 'chromEnds'};
        blockBoundariesA = [chromStartsA + 1, chromEndsA];
        blockBoundariesB = [chromStartsB + 1, chromEndsB];
        [onlyBlockA, onlyBlockB] = get_block_diffs(blockBoundariesA, blockBoundariesB);
        chromStartsOnlyA = onlyBlockA(:, 1) - 1;
        chromEndsOnlyA = onlyBlockA(:, 2);
        chromStartsOnlyB = onlyBlockB(:, 1) - 1;
        chromEndsOnlyB = onlyBlockB(:, 2);
        chromOnlyA = repmat(uniqChrom, size(onlyBlockA, 1), 1);
        chromOnlyB = repmat(uniqChrom, size(onlyBlockB, 1), 1);
        bodyDataCellsOnlyA{uniqChromNum} = horzcat(chromOnlyA, num2cell(chromStartsOnlyA), num2cell(chromEndsOnlyA));
        bodyDataCellsOnlyB{uniqChromNum} = horzcat(chromOnlyB, num2cell(chromStartsOnlyB), num2cell(chromEndsOnlyB));
    end
    bodyDataCellsOnlyA = vertcat(bodyDataCellsOnlyA{:});
    bodyDataCellsOnlyB = vertcat(bodyDataCellsOnlyB{:});
    tBodyDataCellsOnlyA = table(bodyDataCellsOnlyA);
    tBodyDataCellsOnlyB = table(bodyDataCellsOnlyB);
    writetable(tBodyDataCellsOnlyA,'tabledata_a_only.bed','Delimiter','\t', 'FileType', 'text', 'WriteVariableNames', false);
    writetable(tBodyDataCellsOnlyB,'tabledata_b_only.bed','Delimiter','\t', 'FileType', 'text', 'WriteVariableNames', false);
end