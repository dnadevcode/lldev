classdef ImportItemContext < handle
    properties (Constant)
        Version = [0, 0, 1];
    end
    properties
        AppSession

        ImportSrcPath = '';
        SrcSelectionTime

        ListableDataItems
        DataItemUpdateTime
    end
    methods
        function [iic] = ImportItemContext(srcPath, srcSelectionTime, listableDataItems, dataItemUpdateTime)
            % IMPORTITEMCONTEXT - Constructor for the IMPORTITEMCONTEXT
            %   object
            %
            % Inputs:
            %   srcPath
            %     The path to the source
            %   srcSelectionTime (optional; defaults to current time)
            %     The time the source was selected
            %   listableDataItems (optional; defaults to empty cell array)
            %     The cell array of listable data items associated with the
            %     imported item
            %   dataItemUpdateTime (optional; defaults to empty array)
            %     The time the data item was updated
            %     
            % 
            % Outputs:
            %   iic
            %     IMPORTITEMCONTEXT object containing contextual
            %     information about the import of the item
            
            if nargin < 2
                srcSelectionTime = [];
            end
            if isempty(srcSelectionTime)
                srcSelectionTime = clock();
            end
            if nargin < 3
                listableDataItems = [];
            end
            if isempty(listableDataItems)
                listableDataItems = cell(0, 1);
            end
            if nargin < 4
                dataItemUpdateTime = [];
            end
            import Fancy.AppMgr.AppSession;
            appSession = AppSession.get_instance();
            
            iic.AppSession = appSession;
            
            iic.ImportSrcPath = srcPath;
            iic.SrcSelectionTime = srcSelectionTime;
            
            iic.ListableDataItems = listableDataItems;
            iic.DataItemUpdateTime = dataItemUpdateTime;
        end
    
        function [] = update_item(iic, listableDataItems, dataItemUpdateTime)
            % UPDATE_ITEM - updates the listable data items and dat item
            %  update time
            % 
            % Inputs:
            %   iic
            %     the ImportItemContext object
            %   listableDataItems
            %     The cell array of listable data items associated with the
            %     imported item
            %   dataItemUpdateTime (optional; defaults to current time)
            %     The time the data item was updated
            %     
            % 
            % Authors:
            %   Saair Quaderi
            if nargin < 3
                dataItemUpdateTime = clock();
            end
            iic.ListableDataItems = listableDataItems;
            iic.DataItemUpdateTime = dataItemUpdateTime;
        end
    end
end