function [] = plot_cost_matrix(hAxis, costMatrix, yxCoords)
    % Plots the cost matrix together with the warping path in a new
    
    hold(hAxis, 'on');
    axes(hAxis);
    imagesc(costMatrix);
    colormap(hAxis, 'Gray');
    hColorbar = colorbar('peer', hAxis);
    hColorbar.Label.String = 'Cost';
    
    plot(hAxis, yxCoords(:,2), yxCoords(:,1), 'ro');
    
    title(hAxis, 'Cost Matrix')
    ylabel(hAxis, 'X Index')
    xlabel(hAxis, 'Y Index')
    hold(hAxis, 'off');
end