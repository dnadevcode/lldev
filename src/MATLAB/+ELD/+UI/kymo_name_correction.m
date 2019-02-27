function output_kymoStructs = kymo_name_correction(input_kymoStructs)

numStructs = numel(input_kymoStructs);
displayNames = cell(numStructs);

for structNum = 1:numStructs
    displayNames{structNum} = input_kymoStructs(structNum).displayName;
end

for structToModify = 1:numStructs
    equalNames = ismember(displayNames,displayNames{structToModify});
    equalNames(structToModify) = 0;
    for 

end

