classdef (Abstract) AbsMessageManager < handle
    % ABSMESSAGEMANAGER - Abstract class for message management
    %  (the class is abstract because a class which implements this must
    %  fill in the missing functionality for deleting characters from
    %  the output and appending a new string)
    %
    % Authors:
    %   Saair Quaderi
    
    properties (Access = protected)
        msgStack = cell(0, 2);
    end
    
    methods (Static = true, Access = protected, Abstract = true)
        
        append_str(strToAppend) % functionality for appending a string
        
        delete_n_chars(deletionLen) %functionality for deleting last n characters
    end
    
    methods(Access = protected)
        function msgStackOut = get_message_stack(msgMgr)
            % GET_MESSAGE_STACK - returns message IDs and texts in the
            %   internal message stack
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %
            % Outputs:
            %   msgStackOut
            %      Nx2 cell array when there are N messages in the stack
            %      the first column contains message IDs
            %      the second column contains associated message texts
            %
            % Authors:
            %   Saair Quaderi
            
            msgStackOut = msgMgr.msgStack;
        end
        
        function msgIdxs = get_idxs_by_msgID(msgMgr, msgID)
            % GET_IDXS_BY_MSGID - retrieves the message stack indices
            %   associated with a message ID
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %   msgID
            %     the message ID string
            %
            % Outputs:
            %   msgIdxs
            %     the message stack indices for the messages
            %     from the internal message stack which have the same
            %     messageID strings
            %
            % Authors:
            %   Saair Quaderi
            
            msgIdxs = find(cellfun(@(currMsgID) strcmp(currMsgID, msgID), msgMgr.msgStack(:, 1)));
        end
        
        function [] = update_messages_by_idxs(msgMgr, repMsgIdxs, newMsgTexts)
            % UPDATE_MESSAGES_BY_IDXS - handles updating (i.e. replacing)
            %   of previous messages
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %   repMsgIdxs
            %     the message stack indices of previous messages from the
            %     internal message stack to erase
            %   newMsgs
            %     the replacement messages
            %     if it is a string (character vector), all the messages at
            %     the specified indices will be replaced with this message
            %     text
            %     if it is a cell array, each kth entry should replace the
            %     message specified by the kth value in idxs
            %
            % Side-effects:
            %    replaces the messages at the indices specified in the
            %    internal stack and runs the delete character functionality
            %    for all the messages including and after the first of the
            %    messages to be replaced and then the append string
            %    functionality for all the (revised and left alone) message
            %    texts since the deletion
            %
            % Authors:
            %   Saair Quaderi
            
            if not(iscell(newMsgTexts)) && ischar(newMsgTexts)
                newMsgTexts = arrayfun(@(x) newMsgTexts, repMsgIdxs(:), 'UniformOutput', false);
            end
            n = size(msgMgr.msgStack, 1);
            if any(repMsgIdxs ~= min(max(repMsgIdxs, 1), n))
                error('Bad indices');
            end
            minIdx = min(repMsgIdxs);
            erasedMsgStack = msgMgr.erase_last_k_messages(n + 1 - minIdx);
            erasedMsgStack(1 + (repMsgIdxs - minIdx), 2) = newMsgTexts;
            msgMgr.append_messages(erasedMsgStack);
        end
    end
    
    methods
        function [] = clear_stack(msgMgr)
            % CLEAR_STACK - empties the internal message stack
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %
            % Side-effects:
            %   the internal message stack is reset to an empty stack
            %
            % Authors:
            %   Saair Quaderi
            
            msgMgr.msgStack = cell(0, 2);
        end
        
        function msgIdxs = append_messages(msgMgr, newMsgStack)
            % APPEND_MESSAGES - handles appending of new messages
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %   newMsgStack
            %     the message stack to append to the internal message stack
            %     in the form of an Mx2 cell array containing M messages
            %     where the first column contains message IDs and the
            %     second column contains message texts
            %
            % Outputs:
            %   msgIdxs
            %     the message stack indices for the newly appended messages
            %     from the internal message stack
            %
            % Side-effects:
            %    appends the new message stack onto the internal message
            %    stack and handles them elsewhere through the append string
            %    functionality
            %
            % Authors:
            %   Saair Quaderi
            
            n = size(msgMgr.msgStack, 1);
            msgIdxs = n + (1:size(newMsgStack, 1));
            msgMgr.append_str([newMsgStack{:, 2}]);
            msgMgr.msgStack = [msgMgr.msgStack; newMsgStack];
        end
        
        function erasedMsgStack = erase_last_k_messages(msgMgr, k)
            % ERASE_LAST_K_MESSAGES - handles erasing of previous messages
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %   k
            %     the number of previous messages (from the stack) to erase
            %
            % Outputs:
            %  erasedMsgStack
            %    the stack of messages removed from the internal message
            %    stack
            %
            % Side-effects:
            %    removes the last k messages from the internal message
            %    stack and handles them elsewhere through the character
            %    deletion functionality
            %
            % Authors:
            %   Saair Quaderi
            
            k = min(k, size(msgMgr.msgStack, 1));
            deletionLen = 0;
            for messageNum=1:k
                msgItem = msgMgr.msgStack(end, :);
                deletionLen = deletionLen + length(msgItem{2});
            end
            erasedMsgStack = msgMgr.msgStack((1 + end - k):end, :);
            msgMgr.msgStack((1 + end - k):end, :) = [];
            msgMgr.delete_n_chars(deletionLen);
        end
        
        function update_msgs_by_id(msgMgr, repMsgID, newMsgText)
            % UPDATE_MESSAGES_BY_ID - handles updating (i.e. replacing) of
            %   previous messages associated with a message ID
            %
            % Inputs:
            %   msgMgr
            %     the message manager object of this class
            %   repMsgID
            %     the message ID of the messages to be replaced
            %   newMsgTxt
            %     the replacement text for the messages to be updated
            %
            % Side-effects:
            %    replaces the messages associated with the specified
            %    message ID in the internal stack and runs the delete
            %    character functionality
            %    for all the messages including and after the first of the
            %    messages to be replaced and then the append string
            %    functionality for all the (revised and left alone) message
            %    texts since the deletion
            %
            % Authors:
            %   Saair Quaderi
            
            repMsgIdxs = msgMgr.get_idxs_by_msgID(repMsgID);
            newMsgTexts = arrayfun(@(x) newMsgText, repMsgIdxs(:), 'UniformOutput', false);
            msgMgr.update_messages_by_idxs(repMsgIdxs, newMsgTexts);
        end
    end
    
end

