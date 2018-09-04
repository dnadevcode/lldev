function [hTabISD] = add_infoscore_hist_tab(ts, infoScores)
    % ADD_INFOSCORE_HIST_TAB - Plots the distribution of information
    %   scores for the various molecules in a histogram in a new tab
    %
    % Inputs:
    %   ts
    %      TabbedScreen object
    %   infoScores
    %      vector of information score values
    %
    %  Outputs:
    %    hTabISD
    %      the handle for the created tab
    %
    % Authors:
    %  Saair Quaderi


    hTabISD = ts.create_tab('Information Score Distribution');
    hPanelISD = uipanel('Parent', hTabISD);
    hAxisISD = axes('Parent', hPanelISD);
    hist(hAxisISD, infoScores);
    xlabel(hAxisISD, 'Information Score');
    ylabel(hAxisISD, 'Molecules');
    set(get(hAxisISD,'child'),...
        'FaceColor', 'k',...
        'EdgeColor', 'k');
end