classdef ConsoleMenuPrompt < handle
    % CONSOLEMENUPROMPT - Console Menu Prompt
    %
    % Authors:
    %  Saair Quaderi (SQ)
    
    properties (GetAccess = public, SetAccess = protected)
        PromptText = 'Please select one of the options listed below by entering the associated option number';
        OptionDescriptions = cell(0,1)
        OptionCallbacks = cell(0,1)
        OptionNumbers = NaN(0,1);
    end
    
    methods
        function [cmp] = ConsoleMenuPrompt()
            % CONSOLEMENUPROMPT (constructor)
        end
        
        function [] = set_prompt_text(cmp, promptText)
            validateattributes(promptText, {'char'}, {'row'}, 2);
            cmp.PromptText = promptText;
        end
        
        function [] = add_option(cmp, optionDescription, optionCallback, optionNumber)
            validateattributes(optionDescription, {'char'}, {'row'}, 2);
            validateattributes(optionCallback, {'function_handle'}, {'scalar'}, 3);
            
            if nargin < 4
                maxOptNum = max([-1; cmp.OptionNumbers]);
                optionNumber = maxOptNum + 1;
            else
                validateattributes(optionNumber, {'numeric'}, {'scalar', 'integer', 'nonnegative'}, 4);
                if any(cmp.OptionNumbers == optionNumber)
                    error('Duplicate option numbers not permitted');
                end
            end
            cmp.OptionDescriptions = [cmp.OptionDescriptions; {optionDescription}];
            cmp.OptionCallbacks = [cmp.OptionCallbacks; {optionCallback}];
            cmp.OptionNumbers = [cmp.OptionNumbers; optionNumber];
        end
        
        function [] = remove_option(cmp, removeOptionNumber)
            newIdxs = 1:length(cmp.OptionNumbers);
            newIdxs = newIdxs(cmp.OptionNumbers ~= removeOptionNumber);
            
            cmp.OptionDescriptions = cmp.OptionDescriptions(newIdxs);
            cmp.OptionCallbacks = cmp.OptionCallbacks(newIdxs);
            cmp.OptionNumbers = cmp.OptionNumbers(newIdxs);
        end
        
        function [] = list_options(cmp)
            [sortedOptionNumbers, reordering] = sort(cmp.OptionNumbers);
            sortedOptionDescriptions = cmp.OptionDescriptions(reordering);
            numOptions = length(sortedOptionNumbers);
            for optionIdx = 1:numOptions
                fprintf(' %d. %s\n', sortedOptionNumbers(optionIdx), sortedOptionDescriptions{optionIdx});
            end
        end
        
        function [] = display_prompt_text(cmp)
            fprintf('%s: \n', cmp.PromptText);
        end
        
        
        function [] = run_prompt(cmp)
            cmp.display_prompt_text();
            cmp.list_options();
            if length(cmp.OptionNumbers) < 2
                warning('There were fewer than two options');
                if not(isempty(cmp.OptionCallbacks))
                    callback_fn = cmp.OptionCallbacks{1};
                    fprintf('Auto-selecting option #%d', cmp.OptionNumbers(1)); 
                    callback_fn();
                end
                return;
            end
            validSelection = false;
            while not(validSelection)
                fprintf('\nSelect an option: ');
                inputText = input('','s');
                
                if any(cmp.OptionNumbers == 0) && (strcmp(inputText, '') == 1)
                    fprintf('\nSelecting default option #0?\n Just press enter (or enter ''Y'') to continue with the default.\n (Enter anything else to repeat the previous prompt.)\n');
                    inputText2 = input('','s');
                    if (strcmp(inputText2, '') == 1) || (strcmpi(inputText2, 'Y') == 1)
                        selectedOptionNumber = 0;
                    else
                        cmp.run_prompt();
                        return;
                    end
                else
                    [selectedOptionNumber] = str2double(inputText);
                end
                selectionIdx = find(cmp.OptionNumbers == selectedOptionNumber);
                validSelection = (length(selectionIdx) == 1);
                if not(validSelection)
                    fprintf('\nInvalid entry, please try again!');
                else
                    callback_fn = cmp.OptionCallbacks{selectionIdx};
                    callback_fn(); 
                end
            end
        end
    end
end

