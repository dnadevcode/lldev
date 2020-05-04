function export_detected_channel_as_multitif(kymos,settings)
    
    defaultOutputDirpath = settings.dirs.rawChannels;

    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    defaultOutputFilename = sprintf('detectedchannels_%s.tiff', timestamp);
    defaultOutputFilepath = fullfile(defaultOutputDirpath, defaultOutputFilename);


    try
        imwrite(kymos{1}, defaultOutputFilepath)
        for i=2:length(kymos)
            imwrite(kymos{i}, defaultOutputFilepath, 'writemode', 'append');            
        end
       disp(strcat('Saved detected channels multi-tiff to ',defaultOutputFilepath));
        
    catch
        warning('Failed to export multi-frame tiff');
    end
    
end

