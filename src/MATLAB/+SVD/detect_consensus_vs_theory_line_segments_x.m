function [] = detect_consensus_vs_theory_line_segments_x(ts, consensusCurve, theoryCurve)
    % DETECT_CONSENSUS_VS_THEORY_LINE_SEGMENTS_X = Line segment detection consensus vs theory
    %
    % Creates a matrix with pixelwise comparisons
    % between a consensus and a theoretical sequence, and highlights
    % similar regions.
    %
    % Authors:
    %   Erik Lagerstedt
    %   Saair Quaderi (refactoring)
    %
    % This is not a final version. There is much code that can be removed and
    % other parts that can be rewritten. It is similar to 
    % cb_linesegmentdetectionp, but that function is using another (and 
    % possibly better) algorithm to create the binary matrix.
    

    % Dynamic time warp is used to find the
    % direction the barcodes should have. Probably a bit wasteful.

    indelRelCost = 40;
    import SVD.Core.compute_dtw;
    [dtwUnnormalizedDist, ~, ~, ~] = compute_dtw(consensusCurve, theoryCurve, indelRelCost, indelRelCost);
    [dtwUnnormalizedDistFlipped, ~, ~, ~] = compute_dtw(flip(consensusCurve), theoryCurve, indelRelCost, indelRelCost);
    if dtwUnnormalizedDistFlipped < dtwUnnormalizedDist
        consensusCurve = flip(consensusCurve);
    end

    fprintf('"G" (lower is better): %g\n', dtwUnnormalizedDist/length(consensusCurve));

    % Here the matrix is created. Each pixel is the squared difference
    % between consensusCurve and theoryCurve in the corresponding point. The log
    % towards the end is a way to rescale it.

    squaredDiffsMat = bsxfun(@minus, consensusCurve(:), theoryCurve(:)').^2;
    logSquaredDiffsMat = log(squaredDiffsMat);%+1

    % Each element in the matrix is set to 1 or 0, to get a black-and-white
    % image, which then can be evaluated.
    xs2 = logSquaredDiffsMat < 1.5 * mean(logSquaredDiffsMat(:));
    %xs2=utils_findMatchingRegions( 10, 44, 0.4, theoryCurve, consensusCurve )';

    
    
    hTabA = ts.create_tab('A');
    hPanelA = uipanel('Parent', hTabA);
    hAxisA = axes('Parent', hPanelA);
    colormap(hAxisA, gray());
    axes(hAxisA);
    imagesc(~xs2);

    % Some filters are applied to enhance and detect the lines.
    sigmaTV = 0.5;
    sizeTV = 2;
    x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    gaussFilter = gaussFilter / sum(gaussFilter);
    xs2 = filter(gaussFilter,1, xs2);
    xs2 = filter(gaussFilter,1, xs2');
    xs2 = xs2';
    
    
    hTabB = ts.create_tab('B');
    hPanelB = uipanel('Parent', hTabB);
    hAxisB = axes('Parent', hPanelB);
    colormap(hAxisB, gray());
    axes(hAxisB);
    imagesc(abs(xs2-1));

    import ThirdParty.RankOrderFilter.RankOrderFilter;
    xs5=fliplr(RankOrderFilter(xs2,20,30)); %TODO: ang of 45
    xs6=RankOrderFilter(fliplr(xs2),20,30); %TODO: ang of -45

    sigmaTV = 0.5;
    sizeTV = 2;
    x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    gaussFilter = gaussFilter / sum(gaussFilter);
    xs5 = filter(gaussFilter,1, xs5);
    sigmaTV = 0.5;
    sizeTV = 2;
    x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    gaussFilter = gaussFilter / sum(gaussFilter);
    xs6 = filter(gaussFilter,1, xs6);


    [xs7,xs7T,xs7R]=hough(xs5>0,'Theta',-45);

    xs7c=houghlines(xs5,xs7T,xs7R,houghpeaks(xs7, 20),'FillGap',10,'MinLength',50);

    hTabC = ts.create_tab('C');
    hPanelC = uipanel('Parent', hTabC);
    hAxisC = axes('Parent', hPanelC);
    colormap(hAxisC, gray());
    axes(hAxisC);
    imagesc(abs((xs5>0)-1)), colormap(gray);
    
    hold(hAxisC, 'on');
    for it=1:length(xs7c)
        xy = [xs7c(it).point1; xs7c(it).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','r');
    end
    hold(hAxisC, 'off');
    set(hAxisC, 'XTick',[]);
    set(hAxisC, 'YTick',[]);


    [xs8,xs8T,xs8R]=hough(xs6>0,'Theta',45);

    xs8c = houghlines(xs6,xs8T,xs8R,houghpeaks(xs8, 20),'FillGap',10,'MinLength',50);

    
    hTabD = ts.create_tab('D');
    hPanelD = uipanel('Parent', hTabD);
    hAxisD = axes('Parent', hPanelD);
    colormap(hAxisD, gray());
    axes(hAxisD);
    imagesc(abs((xs6>0)-1)), colormap(gray);
    hold(hAxisD, 'on');
    for it=1:length(xs8c)
        xy = [xs8c(it).point1; xs8c(it).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','r');
    end
    hold(hAxisD, 'off');
    set(hAxisD, 'XTick',[]);
    set(hAxisD, 'YTick',[]);

    gmcc = zeros(length(xs7c),1);
    tmcc = zeros(length(xs8c),1);

    % The detected lines are saved and drawn.
    
    hTabE = ts.create_tab('E');
    hPanelE = uipanel('Parent', hTabE);
    hAxisE = axes('Parent', hPanelE);
    colormap(hAxisE, gray());
    axes(hAxisE);
    imagesc(abs(((xs5+xs6)>0)-1)), colormap(gray);
    hold(hAxisE, 'on');
    
    
    hTabF = ts.create_tab('F');
    hPanelF = uipanel('Parent', hTabF);
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsF = TabbedScreen(hPanelF);
    for it = 1:length(xs7c)
        xy = [xs7c(it).point1; xs7c(it).point2];

        %CC for the matching fragments
        conSec=consensusCurve(xs7c(it).point1(1,2):xs7c(it).point2(1,2));
        thySec=theoryCurve(xs7c(it).point1(1,1):xs7c(it).point2(1,1));
        if length(conSec)==length(thySec)
            gmcc(it)=sum(conSec.*thySec)/(norm(conSec)*norm(thySec));
        else
            if length(conSec)>length(thySec)
                conSec=conSec(1:length(thySec));
            else
                thySec=thySec(1:length(conSec));
            end
            gmcc(it)=sum(conSec.*thySec)/(norm(conSec)*norm(thySec));
        end


        hSubtabTmpF = tsF.create_tab(sprintf('%d', it));
        hSubpanelTmpF = uipanel('Parent', hSubtabTmpF);
        hAxisTmpF = axes('Parent', hSubpanelTmpF);
        plot(hAxisTmpF, conSec);
        hold(hAxisTmpF, 'on');
        plot(hAxisTmpF, thySec,'r')
        xlabel(hAxisTmpF, gmcc(it));
        hold(hAxisTmpF, 'off');
    end
    
    hTabG = ts.create_tab('G');
    hPanelG = uipanel('Parent', hTabG);
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsG = TabbedScreen(hPanelG);
    for it = 1:length(xs8c)

        %CC for the matching fragments
        if xs8c(it).point2(1,1)<xs8c(it).point1(1,1)
            conSec=consensusCurve(xs8c(it).point1(1,2):xs8c(it).point2(1,2));
            thySec=fliplr(theoryCurve(xs8c(it).point2(1,1):xs8c(it).point1(1,1)));
        else
            conSec=consensusCurve(xs8c(it).point2(1,2):xs8c(it).point1(1,2));
            thySec=fliplr(theoryCurve(xs8c(it).point1(1,1):xs8c(it).point2(1,1)));            
        end
        if length(conSec)==length(thySec)
            tmcc(it)=sum(conSec.*thySec)/(norm(conSec)*norm(thySec));
        else
            if length(conSec)>length(thySec)
                conSec=conSec(1:length(thySec));
            else
                thySec=thySec(1:length(conSec));
            end
            tmcc(it)=sum(conSec.*thySec)/(norm(conSec)*norm(thySec));
        end

        hSubtabTmpG = tsG.create_tab('X');
        hSubpanelTmpG = uipanel('Parent', hSubtabTmpG);
        hAxisTmpG = axes('Parent', hSubpanelTmpG);
        plot(hAxisTmpG, conSec)
        hold(hAxisTmpG, 'on');
        plot(hAxisTmpG, thySec,'r');
        xlabel(hAxisTmpG, tmcc(it));
        hold(hAxisTmpG, 'off');
    end

    % The image is ploted, and the lines are drawn on it. The cross
    % correlation for the region under the line is displayed.
    
    hTabH = ts.create_tab('H');
    hPanelH = uipanel('Parent', hTabH);
    hAxisH = axes('Parent', hPanelH);
    imagesc(abs(xs2-1), 'Parent', hAxisH);
    colormap(hAxisH, gray());
    hold(hAxisH, 'on');
    for it=1:length(xs7c)
        xy = [xs7c(it).point1; xs7c(it).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',3,'Color','g');
        if gmcc(it)>0.6
            text(xs7c(it).point1(1,1),xs7c(it).point1(1,2),num2str(gmcc(it)),'Color','g','FontWeight','bold')
        end
    end
    for it=1:length(xs8c)
        xy = [xs8c(it).point1; xs8c(it).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',3,'Color','r');
        if tmcc(it)>0.6
            text(xs8c(it).point1(1,1),xs8c(it).point1(1,2),num2str(tmcc(it)),'Color','r','FontWeight','bold')
        end
    end
    hold(hAxisH, 'off');
    
    set(hAxisH, ...
        'XTick', [], ...
        'YTick', []);

    % [xs5a, xs5b, xs5c] = hough(xs5);
    % [xs6a, xs6b, xs6c] = hough(xs6);
    % xs5 = houghlines(xs2, xs5b, xs5c, houghpeaks(xs5a, 3));
    % xs6 = houghlines(xs6, xs6b, xs6c, houghpeaks(xs6a, 3));
    % 
    % sigmaTV = 5;
    % sizeTV = 30;
    % x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    % gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    % gaussFilter = gaussFilter / sum(gaussFilter);
end