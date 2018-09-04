classdef ListableDataItem < handle
    % LISTABLEDATAITEM - Listable data item represents data
    %   that can be displayed in a list and refers to a data item
    %   managed in AppDataPoolMgr. These listable data items
    %   may also be associated with tag strings
    %
    % Authors:
    %   Saair Quaderi
    properties (Constant)
        Version = [0, 0, 1];
    end
    properties (SetAccess = private)
        DisplayName = '';
        DataPoolID = '';
        DataItemID = '';
        Tags = cell(0, 1);
    end
    methods
        function [listableDataItem] = ListableDataItem(displayName, dataPoolID, dataItemID, tags)
            if nargin < 4
                tags = cell(0, 1);
            end
            import AppMgr.ListableDataItem;
            [isValidTF, errMsg] = ListableDataItem.check_validity(displayName, dataPoolID, dataItemID);
            if not(isValidTF)
                error(errMsg);
            end
            listableDataItem.DisplayName = displayName;
            listableDataItem.DataPoolID = dataPoolID;
            listableDataItem.DataItemID = dataItemID;
            listableDataItem.add_tags(tags);
        end
        
        
        function [hasTagTF] = has_tag(listableDataItem, tag)
            hasTagTF = any(strcmp(listableDataItem.Tags, tag));
        end
        function [hasTagMask] = has_tags(listableDataItem, tags)
            hasTagMask = cellfun(@listableDataItem.has_tag, tags);
        end
        function [] = add_tag(listableDataItem, tag)
            listableDataItem.add_tags({tag});
        end
        function [] = add_tags(listableDataItem, tags)
            invalidTagMask = cellfun(...
                @(tag) ...
                    (isempty(tag) || not(ischar(tag)) || not(isrow(tag))), ...
                    tags);
            if any(invalidTagMask)
                warning('Tags which were not nonempty strings are being ignored');
            end
            validTags = tags(not(invalidTagMask));
            hasTagMask = listableDataItem.has_tags(validTags);
            newValidTags = validTags(not(hasTagMask));
            if not(isempty((newValidTags)))
                listableDataItem.Tags = [listableDataItem.Tags; newValidTags];
            end
        end
        function [] = remove_tag(listableDataItem, tag)
            listableDataItem.remove_tags({tag});
        end
        function [] = remove_tags(listableDataItem, tags)
            hasTagMask = listableDataItem.has_tags(tags);
            listableDataItem.Tags = setdiff(listableDataItem.Tags, tags(hasTagMask));
        end
        
        function [foundDataItemTF, dataItem] = get_value(listableDataItem)
            import AppMgr.AppDataPoolMgr;
            dataPoolID = listableDataItem.DataPoolID;
            dataItemID = listableDataItem.DataItemID;
            dataItemIDs = {dataItemID};
            [dataItems, ~, foundDataItemTF] = AppDataPoolMgr.get_data_items(dataPoolID, dataItemIDs);
            dataItem = dataItems{1};
        end
        
    end
    methods (Static)
        function [listableDataItems] = make_datapool_listable_items(dataPoolID)
            import AppMgr.AppDataPoolMgr;
            import AppMgr.ListableDataItem;
            dataItemIDs = AppDataPoolMgr.get_pool_data_item_ids(dataPoolID);
            displayNames = dataItemIDs;
            listableDataItems = cellfun( ...
                @(dataItemID, displayName) ...
                    ListableDataItem(displayName, dataPoolID, dataItemID), ...
                displayNames, dataItemIDs, ...
                'UniformOutput', false);
        end
    end
    methods (Static, Access = private)
        function [isValidTF, errMsg] = check_validity(displayName, dataPoolID, dataItemID)
            isValidTF = false;
            invalidDisplayNameTF = (...
                isempty(displayName) ...
                || not(ischar(displayName)) ...
                || not(isrow(displayName)));
            if invalidDisplayNameTF
                errMsg = 'Display name must be a nonempty string';
                return;
            end
            invalidDataPoolTF = (...
                isempty(dataPoolID) ...
                || not(ischar(dataPoolID)) ...
                || not(isrow(dataPoolID)) ...
                || not(AppDataPoolMgr.has_data_pool(dataPoolID)));
            import AppMgr.AppDataPoolMgr;
            if invalidDataPoolTF
                errMsg = 'Data pool could not be found';
                return;
            end
            
            [~, ~, validDataItemTF] = AppDataPoolMgr.get_data_item(dataPoolID, dataItemID);
            invalidDataItemTF = not(validDataItemTF);
            if invalidDataItemTF
                errMsg = 'Data item could not be found';
                return;
            end
            isValidTF = true;
            errMsg = [];
        end
    end
end