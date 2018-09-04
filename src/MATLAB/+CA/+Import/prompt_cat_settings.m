function [answersStruct] = prompt_cat_settings(defaultSvalueThreshold, promptForOverlapCost)

    promptDialogTitle = 'Inputs for Contig Assembly';
    fnAsIs = @(x) x;
    fnLogicalScalarToYesNo = @(x) feval(@(a, b) a{b}, {'Yes'; 'No'}, 1 + (~x));
    fnIsYesStr = @(x) strcmpi(x, 'Yes');
    fnIsNotNoStr = @(x) not(strcmpi(x, 'No'));

    promptsData = {
        'dataSampleName', 'Sample name:', 'Unknown', fnAsIs, fnAsIs;
        'numPixelsTrimmed', 'Number of pixels to cut:', 2, @num2str, @str2double;
        'sValueThreshold', 'S-value threshold:', defaultSvalueThreshold, @num2str, @str2double;
    };


    if promptForOverlapCost
        promptsData = [promptsData; {
            'overlapCost', 'Overlap cost:', 0.5, @num2str, @str2double;
        }];
    end
    promptsData = [promptsData; {
        'contigsShareSameDir', 'Contigs share the same direction?', false, fnLogicalScalarToYesNo, fnIsNotNoStr;
        'isPlasmid', 'Is plasmid?', true, fnLogicalScalarToYesNo, fnIsYesStr;
        'isFullyCovered', 'Fully covered?', false, fnLogicalScalarToYesNo, fnIsNotNoStr
    }];
    promptFieldnames = promptsData(:, 1);
    if any(not(cellfun(@strcmp, promptFieldnames, matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(promptFieldnames)))))
        error('Invalid prompt field names');
    end
    numPrompts = size(promptsData, 1);

    promptDescriptions = promptsData(:, 2);
    promptDefaultVals = promptsData(:, 3);
    promptStringifyFns = promptsData(:, 4);
    promptDestringifyFns = promptsData(:, 5);
    num_lines = 1;
    defaultValStrs = cellfun(@(fnStringify, defaultVal) fnStringify(defaultVal), promptStringifyFns,  promptDefaultVals, 'UniformOutput', false);
    answersStrs = inputdlg(promptDescriptions, promptDialogTitle, num_lines, defaultValStrs);
    answers = cellfun(@(fnDestringify, answerStr) fnDestringify(answerStr), promptDestringifyFns, answersStrs, 'UniformOutput', false);

    answersStruct = struct();
    for promptNum = 1:numPrompts
        answersStruct.(promptFieldnames{promptNum}) = answers{promptNum};
    end
end