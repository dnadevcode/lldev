classdef (Sealed) DataManager < handle
    % DATAMANAGER - Data messenger
    %
    % Note: An instance of DATAMANAGER should be retrieved
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
    end
    
    methods (Access = private)
        function [dataMgr] = DataManager()
            % DATAMANAGER - Constructor, purposefully made
            % private to follow Singleton design pattern:
            %
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            %
            % Use get_instance publicly
        end
    end
    
    methods (Static)
        function [singletonDataMgr] = get_instance()
            % GET_INSTANCE - retrieves the single instance of this data
            %   manager
            %
            % Outputs:
            %   singletonDm
            %     the instance of the data manager
            %
            % Side-effects:
            %   Creates the local persistent data manager if it does not
            %   already exist
            %
            % Authors:
            %   Saair Quaderi
         
            % Part of the Singleton design pattern:
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            persistent localPersisentDataMgr;
            if isempty(localPersisentDataMgr) || not(isvalid(localPersisentDataMgr))
                localPersisentDataMgr = FancyIO.FancyDB.DataManager();
            end
            singletonDataMgr = localPersisentDataMgr;
        end
    end
    
    methods
        function [errMsg, successFlag] = save_data_item(dataMgr, dataItem)
            errMsg = '';
            successFlag = false;
            validateattributes(dataItem, {'FancyIO.FancyDB.DataItem'}, {'scalar'}, 2);
        end
    end
    
end

