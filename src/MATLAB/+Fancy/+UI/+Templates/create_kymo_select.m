function [cache] = create_kymo_select(kymo,cache )
    % create_kymo_select 
    if nargin < 2
        cache = containers.Map();
    end

    
%     
%         hFig = figure('Name', 'Kymo selection', ...
%             'Units', 'normalized', ...
%             'OuterPosition', [0 0 0.5 0.5], ...
%             'NumberTitle', 'off', ...
%             'MenuBar', 'none' ...
%         );
% 
%         hFig1 = figure('Name', 'Kymo selection', ...
%             'Units', 'normalized', ...
%             'OuterPosition', [0 0 0.5 0.5], ...
%             'NumberTitle', 'off', ...
%             'MenuBar', 'none' ...
%         );
% %     
%         import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
%         hNewAxes = generate_axes_grid(hFig1, 1);
%         imagesc(kymo, 'Parent', hNewAxes(1));
%         hold(hNewAxes(1), 'on');
%         colormap(hNewAxes(1), gray());
%         
        PushButton = uicontrol(gcf,'Style', 'push', 'String', 'Next','Position', [0.2 0.2 0.2 0.2],'CallBack', @fun);


       
        function fun(ObjectH, EventData)
            cache('button') = 1;
        end
        
end

