function shouldContinue = prompt_should_continue_fitting()
    inputStr = input('Continue fitting  (Y/N)? ','s');
    if strcmpi(inputStr, 'Y') || strcmpi(inputStr, 'YES') 
        shouldContinue = true;
        return;
    elseif strcmpi(inputStr, 'N') || strcmpi(inputStr, 'NO') 
        shouldContinue = false;
        return;
    else
        disp('Please answer "Y" for Yes to continue or "N" for No to stop');
        shouldContinue = prompt_should_continue_fitting();
        return;
    end
end