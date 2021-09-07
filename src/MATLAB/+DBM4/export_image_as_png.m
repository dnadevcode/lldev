function [] = export_image_as_png(dbmODW, fileIdxs, fileMoleculeIdxs, kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs,pngOutputFilepaths)

     %
    rawKymos = dbmODW.get_raw_kymos(fileIdxs, fileMoleculeIdxs);

    kymoSrcFilenames = dbmODW.get_molecule_src_filenames(fileIdxs);

    numKymos = numel(rawKymos);

    % helper functions. might not be needed as we already have the name in
    % filename..
%     import OldDBM.General.UI.Helper.get_header_texts;
%     headerTexts = get_header_texts(fileIdxs, fileMoleculeIdxs, kymoSrcFilenames);
    import OldDBM.General.UI.set_centered_header_text;


    parfor kymoNum = 1:numKymos
        f=figure('visible','off');
        kymo = rawKymos{kymoNum};
%             hAxisKymo = hAxesKymos(kymoNum);

        axx = axes(f); %#ok<LAXES>
        imagesc(kymo);
        colormap(f, gray());
        set(axx, ...
            'XTick', [], ...
            'YTick', []);
        box(axx, 'on');

%         if not(isempty(headerTexts))
%              headerText = headerTexts{kymoNum};
%             set_centered_header_text(axx, headerText, [1 1 0], 'none');
%         end

        hold(axx, 'on');
        box('on');

        % Plot the kymograph's edges
        plot(axx, kymosMoleculeLeftEdgeIdxs{kymoNum}, 1:length(kymosMoleculeLeftEdgeIdxs{kymoNum}), 'm-', 'Linewidth', 2);
        plot(axx, kymosMoleculeRightEdgeIdxs{kymoNum}, 1:length(kymosMoleculeRightEdgeIdxs{kymoNum}), 'c-', 'Linewidth', 2);
        hold(axx, 'off');
                
        try
            axisFrame = getframe(axx);
            axisImg = frame2im(axisFrame);
            imwrite(axisImg, pngOutputFilepaths{kymoNum});
        catch
            warning('Failed to export image');
        end
    end
end