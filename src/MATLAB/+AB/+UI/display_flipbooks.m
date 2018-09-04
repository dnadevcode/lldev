function [] = display_flipbooks(labelFlipbook, movieRotCyc)
    % Find the channel coordinates.
    kymoFlipbook = permute(movieRotCyc, [4 1 3 2]);
    kymoFlipbook = repmat(kymoFlipbook, [1 1 3 1]);
    
    import AB.Viz.label2rgb_video;
    rgbLabelFlipbook = label2rgb_video(labelFlipbook);
    vid = [rgbLabelFlipbook, kymoFlipbook];
    % rgbForegroundFlipbook = kymoFlipbook.*feval(@(mask) cat(3, ~mask, mask, mask), labelFlipbook > 0);
    % vid  = [vid; rgbForegroundFlipbook, kymoFlipbook];
    play_video(vid);
end