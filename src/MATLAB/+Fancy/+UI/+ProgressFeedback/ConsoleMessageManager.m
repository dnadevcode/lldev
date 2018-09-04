classdef (Sealed) ConsoleMessageManager < Fancy.UI.ProgressFeedback.AbsMessageManager
    % CONSOLEMESSAGEMANAGER - Concrete class for message management that
    %  extends the Abstract Message Manager by filling in the abstract 
    %  functionality for deleting characters from the output and appending 
    %  a new string to the standard output (i.e. command window)
    %
    % Note: An instance of ConsoleMessageManager should be retrieved using
    %   get_instance since it will be defined as a persistent variable
    %   using the singleton design pattern. Note that all standard output
    %   should go through it to avoid potentially deleting output not meant
    %   to be deleted. (e.g. disps/warnings/lines without semi-colons
    %   may cause trouble)
    %
    % http://mathworks.com/help/matlab/ref/persistent.html
    % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
    %
    % Authors:
    %   Saair Quaderi
    
    methods (Access = private)
        function msgMgr = ConsoleMessageManager()
            % CONSOLEMESSAGEMANAGER - Constructor, purposefully made
            % private to follow Singleton design pattern:
            %
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            %
            % Use get_instance publicly
        end
    end
    
    methods (Static = true)
      function [singletonMsgMgr] = get_instance()
            % GET_INSTANCE - retrieves the single instance of this message
            % manager
            %
            % Outputs:
            %   singletonMsgMgr
            %     the instance of the message manager
            %
            % Side-effects:
            %   Creates the local persistent message manager if it does
            %   not already exist
            %
            % Authors:
            %   Saair Quaderi
         
            % Part of the Singleton design pattern:
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            persistent localPersisentMsgMgr
            if isempty(localPersisentMsgMgr) || not(isvalid(localPersisentMsgMgr))
                localPersisentMsgMgr = Fancy.UI.ProgressFeedback.ConsoleMessageManager();
            end
            singletonMsgMgr = localPersisentMsgMgr;
      end
    end
    
    methods (Static = true, Access = protected)
    
        function [] = append_str(strToAppend)
            % APPEND_STR - appends a string to the standard output (i.e.
            % command window)
            %
            % Inputs:
            %   strToAppend
            %     the string to append to the standard output
            %
            % Side-effects:
            %   adds the string to the displayed text in the standard ouput
            %
            % Authors:
            %   Saair Quaderi
            
            fprintf(1, '%s', strToAppend);
        end
        
        function [] = delete_n_chars(deletionLen)
            % DELETE_N_CHARS - adds N backspace characters to the standard
            %   output (i.e. command window)
            %
            % NOTE: If things are printed to the standard output by code
            %    other than this Console Message Manager while it is being
            %    used that output would be erased instead of the intended
            %    text to be erased!
            %
            % Inputs:
            %   deletionLen
            %     the number of characters that should be erased
            %
            % Side-effects:
            %   adds N backspace characters to the standard
            %   output
            %   Note that this could have unintended consequences if code
            %   other than this Console Message Manager are outputing
            %   things to the standard output while console message manager
            %   is being used
            %
            % Authors:
            %   Saair Quaderi
            fprintf(1, repmat('\b', 1, deletionLen));
        end
    end
    
end

