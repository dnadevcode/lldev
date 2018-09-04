function [localExtremaIdxs, localExtremaVals] = detect_local_extrema(curve, minValDistBetweenAdjExtrema)
    % Note from SQ: This new detect_local_extrema
    %  implementation is different from what was historically used

    import OptMap.SignalProcessing.detect_robust_local_extrema;

    [localExtremaIdxs, localExtremaVals] = detect_robust_local_extrema(curve, minValDistBetweenAdjExtrema);
    return;

    % % Old obsolete implementation (which can have infinite loop issues)
    % % Slightly modified from what used to be called
    % %   CMN_HelperFunctions.robustextrema back in SVN R53
    % 
    %     % Inputs: 
    %     % curve = 1D curve to be analyzed
    %     % minValDistBetweenAdjExtrema = threshold for deeming a peak/valley "robust" or not.
    %     %
    %     % Outputs:
    %     %  localExtremaIdxs, the indices for extrema vals
    %     %  localExtremaVals, the extrema values
    %     %
    %     % By: Tobias Ambjörnsson
    % 
    %     E_hb = diff(curve);
    %     E_th = minValDistBetweenAdjExtrema;
    %     max_no_boundaries = 100;
    % 
    %     k=0;                            % k labels different basepairs
    %     boundary_counter=1;             % counter for number of helix-coil
    %                                     % and coil-helix boundaries 
    %     hc=zeros(max_no_boundaries,1);         
    %                                     % positions of helix-coil boundaries
    %                                     % hc=position of helix-part
    %                                     % of boundary  
    %     ch=zeros(max_no_boundaries,1);         
    %                                     % positions of coil-helix boundaries
    %                                     % ch=position of coil-part
    %                                     % of boundary  
    %     no_of_hc_boundaries=0;          % number of helix-coil boundaries
    %     no_of_ch_boundaries=0;          % number of coil-helix boundaries
    % 
    %     M = length(E_hb);
    %     while k<=M-1 
    % 
    %        % -- helical segment --
    % 
    %        j=k;  % (a possible) energy minimum at position j
    %        E=0;
    %        while k<=M-1 && E<=E_th
    %           k=k+1;
    %           E=E+E_hb(k);
    %           if E<0  % a new possible robust local minima found
    %              j=k;
    %              E=0;    
    %           else % E>=0
    %              if E>E_th
    %                 hc(boundary_counter)=j;       % store position of
    %                                               % helix-coil boundary
    %                                               % hc=position of helix-part
    %                                               % of boundary
    %                 no_of_hc_boundaries=no_of_hc_boundaries+1;  
    % 
    %              end
    %           end
    %        end
    % 
    %        % -- coil segment --
    % 
    %        j=k;   % (a possible) energy maximum at position j
    %        E=0;
    %        while k<=M-1 && E>=-E_th
    %           k=k+1;
    %           E=E+E_hb(k);
    %           if E>0 % a new possible robust local maxima found
    %              j=k;
    %              E=0;
    %           else % E<0
    %              if E<-E_th
    %                 ch(boundary_counter)=j;       % store position of
    %                                               % coil-helix boundary
    %                                               % ch=position of helix-part
    %                                               % of boundary
    %                 no_of_ch_boundaries=no_of_ch_boundaries+1;  
    % 
    %              end
    %           end
    %        end
    % 
    %        boundary_counter=boundary_counter+1;    
    %     end
    % 
    %     localExtremaIdxs = sort([ch(ch>0)' hc(hc>0)'])+1;
    %     localExtremaVals = curve(localExtremaIdxs);
end