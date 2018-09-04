function [] = cb_error_messages(errorMessages)
    numErrors = length(errorMessages);
    for errorNum=1:numErrors
        warning(errorMessages{errorNum});
    end
end
