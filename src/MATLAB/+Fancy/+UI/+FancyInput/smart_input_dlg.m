function [aborted, convertedValues, rawInputValues] = smart_input_dlg(...
    defaultValues, inputNames, inputDialogTitle, numLines,...
    inputValidators, inputFormatConverters,...
    fn_cb_error_messages,...
    fn_cb_simple_input_validator, fn_cb_simple_input_validation_failure,...
    fn_cb_combined_input_validator, fn_cb_combined_input_validation_failure)

    aborted = false;
    convertedValues = [];
    rawInputValues = [];

    if (nargin < 4)|| isempty(numLines)
        textLengths = cellfun(@(x) length(x), [inputDialogTitle; defaultValues(:); inputNames(:)]);
        textLengths(1) = ceil(2*textLengths(1))+ 5;
        maxTextLength = max(textLengths);
        numLines = [1, ceil(1.2.*maxTextLength)];
    end

    if (nargin < 5)
        inputValidators = [];
    end
    if (nargin < 6)
        inputFormatConverters = [];
    end

    if (nargin < 7) || isempty(fn_cb_error_messages)
        import Fancy.UI.FancyInput.cb_error_messages;
		fn_cb_error_messages = @FancyInput.cb_error_messages;
    end
    if (nargin < 8) || isempty(fn_cb_simple_input_validator)
        import Fancy.UI.FancyInput.cb_simple_input_validator;
        fn_cb_simple_input_validator = @cb_simple_input_validator;
    end
    if (nargin < 9) || isempty(fn_cb_simple_input_validation_failure)
	    import Fancy.UI.FancyInput.cb_simple_input_validation_failure;
        fn_cb_simple_input_validation_failure = @cb_simple_input_validation_failure;
    end
    if (nargin < 10) || isempty(fn_cb_combined_input_validator)
        import Fancy.UI.FancyInput.cb_combined_input_validator;
		fn_cb_combined_input_validator = @cb_combined_input_validator;
    end
    if (nargin < 11) || isempty(fn_cb_combined_input_validation_failure)
        import Fancy.UI.FancyInput.cb_combined_input_validation_failure;
        fn_cb_combined_input_validation_failure = @cb_combined_input_validation_failure;
    end

    allValid = false;
    while not(allValid)
        rawInputValues = inputdlg(inputNames, inputDialogTitle, numLines, defaultValues);
        if isempty(rawInputValues)
            aborted = true;
            return;
        end

        [allValid, hasError, errors, convertedValues] = fn_cb_simple_input_validator(rawInputValues, inputValidators, inputNames, inputFormatConverters);
        if not(allValid)
            fn_cb_simple_input_validation_failure(inputNames, rawInputValues, convertedValues, hasError, errors, fn_cb_error_messages);
            defaultValues(~hasError) = rawInputValues(~hasError);
        else
            [allValid, hasError, errors] = fn_cb_combined_input_validator(rawInputValues, convertedValues);
            if not(allValid)
                fn_cb_combined_input_validation_failure(inputNames, rawInputValues, convertedValues, hasError, errors, fn_cb_error_messages);
            end
        end
    end
end
