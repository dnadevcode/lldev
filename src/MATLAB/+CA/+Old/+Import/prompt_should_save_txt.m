function [shouldSave] = prompt_should_save_txt()
    optSaveAsTxt = 'Yes';
    optDontSave = 'No';
    optDefault = optSaveAsTxt;
    selectedChoice = questdlg('Would you like to save as .txt?', 'Save?', optSaveAsTxt, optDontSave, optDefault);
    shouldSave = strcmp(selectedChoice, optSaveAsTxt);
end