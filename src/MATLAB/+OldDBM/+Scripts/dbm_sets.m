function [ sets ] = dbm_sets()
    % returns dbm sets for guiless dbm
    
    sets = [];
    
    sets.averagingWindowWidth = 3;
    
    sets.signalThreshold = 0;
    
    % how many rows to the left and the right of kymo to add
    sets.rowSidePadding = 100;
    
    sets.fgMaskingSettings.maxAmpDist = 2;

end

