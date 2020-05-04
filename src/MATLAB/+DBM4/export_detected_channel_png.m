function export_detected_channel_png(f,settings)
    
    defaultOutputDirpath = settings.dirs.rawChannels;

    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    defaultOutputFilename = sprintf('detectedchannels_%s.png', timestamp);
    defaultOutputFilepath = fullfile(defaultOutputDirpath, defaultOutputFilename);

    try
        axisFrame = getframe(f);
        axisImg = frame2im(axisFrame);
        imwrite(axisImg, defaultOutputFilepath);
        disp(strcat('Saved detected channels png to ',defaultOutputFilepath));
        
    catch
        warning('Failed to export image');
    end
    
end

