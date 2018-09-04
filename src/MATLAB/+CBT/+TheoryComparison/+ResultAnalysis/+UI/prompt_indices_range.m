function indicesToInclude = prompt_indices_range(theoryLengths_bp)
    validateattributes(theoryLengths_bp, {'numeric'}, {'finite', 'vector', 'nondecreasing'}, 1);

    import Fancy.UI.FancyInput.smart_input_dlg;
    import Fancy.Validation.generate_validator;

    choice = menu(...
        'Do you want to restict analysis to a subset of the results based on size?', ...
        'Yes, restrict analysis to results for plasmids in a certain length range', ...
        'No, analyze all the results');
    minIndex = 1;
    maxIndex = length(theoryLengths_bp);
    if choice == 1
        rangeValidator = generate_validator({'scalar', 'integer', {'>=', theoryLengths_bp(minIndex)}, {'<=', theoryLengths_bp(maxIndex)}});

        [aborted, convertedValues, rawInputValues] = smart_input_dlg(...
            {num2str(theoryLengths_bp(minIndex)), num2str(theoryLengths_bp(maxIndex))}, {'Minimum Length', 'Maximum Length'}, 'Select subset length range (in basepairs)', [],...
            {rangeValidator; rangeValidator}, {@str2double, @str2double}, [], [], []);
        if not(aborted)
            minLength = convertedValues{1};
            maxLength = convertedValues{2};
            minIndex = find(theoryLengths_bp >= minLength, 1, 'first');
            maxIndex = find(theoryLengths_bp <= maxLength, 1, 'last');
        end
    end
    indicesToInclude = minIndex:maxIndex;
end