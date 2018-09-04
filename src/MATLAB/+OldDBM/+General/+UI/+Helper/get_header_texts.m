function [headerTexts] = get_header_texts(fileIdxs, fileMoleculeIdxs, fileNames)
    import OldDBM.General.UI.Helper.get_header_text;

    numMolecules = numel(fileIdxs);
    headerTexts = cell(numMolecules, 1);
    for moleculeNum=1:numMolecules
        fileIdx = fileIdxs(moleculeNum);
        fileMoleculeIdx =  fileMoleculeIdxs(moleculeNum);
        fileName = fileNames{moleculeNum};
        headerText = get_header_text(fileIdx, fileMoleculeIdx, fileName);
        headerTexts{moleculeNum} = headerText;
    end
end