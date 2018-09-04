classdef (Sealed) BasicTextProgressMessenger < handle
    % BASICTEXTPROGRESSMESSENGER - Basic text progress messenger
    %  functionality reports percent progress in the standard output
    %
    % Note: An instance of BASICTEXTPROGRESSMESSENGER should be retrieved
    %   using get_instance since it will be defined as a persistent
    %   variable using the singleton design pattern. Note that all standard
    %   output should go through it to avoid potentially deleting output
    %   not meant to be deleted. (e.g. disps/warnings/lines without 
    %   semi-colons may cause trouble)
    %
    % http://mathworks.com/help/matlab/ref/persistent.html
    % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
    %
    % Authors:
    %   Saair Quaderi
    
    properties
        msg_mgr
        prevPortionComplete = NaN;
        portionReportInterval = NaN;
        isFinalized = false;
    end
    
    methods (Access = private)
        function [btpm] = BasicTextProgressMessenger()
            % BASICTEXTPROGRESSMESSENGER - Constructor, purposefully made
            % private to follow Singleton design pattern:
            %
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            %
            % Use get_instance publicly
            import Fancy.UI.ProgressFeedback.ConsoleMessageManager;
            btpm.msg_mgr = ConsoleMessageManager.get_instance();
        end
    end
    
    methods (Static)
        function [singletonBtpm] = get_instance()
            % GET_INSTANCE - retrieves the single instance of this message
            % manager
            %
            % Outputs:
            %   singletonBtpm
            %     the instance of the basic text progress manager
            %
            % Side-effects:
            %   Creates the local persistent basic text progress manager
            %   if it does not already exist
            %
            % Authors:
            %   Saair Quaderi
         
            % Part of the Singleton design pattern:
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            persistent localPersisentBtpm;
            if isempty(localPersisentBtpm) || not(isvalid(localPersisentBtpm))
                localPersisentBtpm = Fancy.UI.ProgressFeedback.BasicTextProgressMessenger();
            end
            singletonBtpm = localPersisentBtpm;
        end
    end
        
    methods
        function [] = init(btpm, taskDescription, customPortionReportInterval)
            % INIT - initializatizes progress reporting for a task
            %
            % Inputs:
            %   btpm
            %     the basic text progress manager
            %   taskDescription
            %     the description of the task
            %   customPortionReportInterval
            %     the amount of change to total progress since the last
            %     reported progress that will trigger reporting the
            %     progress percentage again
            %     positive value no greater than 1 (.01 = 1% and 1=100%)
            % 
            % Side-effects:
            %   Clears the internally tracked message stack and
            %   adds new messages to the stack and standard output
            %   specifying the task and the (start) time and a placeholder
            %   for the status
            % 
            % Authors:
            %   Saair Quaderi
            
            if nargin < 2
                taskDescription = 'Busy...';
            end
            if nargin < 3
                customPortionReportInterval = .1;
            else
                validateattributes(customPortionReportInterval, {'numeric'}, {'real', 'scalar', '>', 0, '<=', 1}, 2);
            end
            timestamp = datestr(clock(), 'HH:MM:SS');
            startTimeStr = sprintf('   Started: %s',  timestamp);
            btpm.prevPortionComplete = NaN;
            btpm.portionReportInterval = customPortionReportInterval;
            btpm.isFinalized = false;
            btpm.msg_mgr.clear_stack();
            btpm.msg_mgr.append_messages({...
                'TaskDescription', taskDescription;...
                'StartTime', startTimeStr;...
                'Status', ''...
                });
        end
        
        function [] = checkin(btpm, numTasksComplete, numTotalTasks)
            % CHECKIN - updates the progress information by providing the
            %   number of tasks that are complete and the number of total
            %   tasks to complete
            %
            % Inputs:
            %   btpm
            %     the basic text progress manager
            %   numTasksComplete
            %     the number of tasks that have been completed
            %   numTotalTasks
            %     the total number of tasks that need to be completed
            %
            % Side-effects:
            %   Updates the internal message stack and the standard output,
            %   by deleting the previously reported status and then
            %   adding the new status information
            %
            %   Note that the deletion will only work as intended if
            %   all the information sent to the standard output is sent
            %   through the ConsoleMessageManager insance while it is being
            %   used
            % 
            % Authors:
            %   Saair Quaderi
            
           portionComplete = double(numTasksComplete)/double(numTotalTasks);
           if (portionComplete == 1) || isnan(btpm.prevPortionComplete) || (portionComplete - btpm.prevPortionComplete > btpm.portionReportInterval)
              btpm.msg_mgr.update_msgs_by_id('Status', sprintf(' Progress: %3.1f%%', portionComplete*100));
              btpm.prevPortionComplete = portionComplete;
           end
        end
        
        function [] = finalize(btpm, completionMsg)
            % FINALIZE - updates the progress information to indicate that
            %   the task has been completed
            %
            % Inputs:
            %   btpm
            %     the basic text progress manager
            %   completionMsg
            %     the message to display now that the task is completed
            %
            % Side-effects:
            %   Updates the internal message stack and the standard output,
            %   by deleting the previously reported status and then
            %   adding the new status information
            %
            %   Note that the deletion will only work as intended if
            %   all the information sent to the standard output is sent
            %   through the ConsoleMessageManager insance while it is being
            %   used
            % 
            % Authors:
            %   Saair Quaderi
            
            if nargin < 2
                completionMsg = '';
            end
            if btpm.isFinalized
                return;
            end
            timestamp = datestr(clock(), 'HH:MM:SS');
            endTimeStr = sprintf(' Completed: %s\n', timestamp);
            btpm.msg_mgr.update_msgs_by_id('Status', '');
            btpm.msg_mgr.append_messages({'EndTime', endTimeStr});
            btpm.msg_mgr.append_messages({'CompletionMsg', completionMsg});
            btpm.isFinalized = true;
        end
    end
    
end

