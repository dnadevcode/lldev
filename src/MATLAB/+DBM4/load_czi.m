function [channelImg,names] = load_czi(filename,max_number_of_frames, channels)

    channelImg = [];
    names = [];
     try
          T = evalc(['data = bfopen(''', filename, ''');']);
      catch
          bfmatlabFold = uigetdir('pwd','Select folder with bfmatlab');
          addpath(genpath(bfmatlabFold));
          try
              T = evalc(['data = bfopen(''', filename, ''');']);
          catch
              warning('Failed to import czi file');
          end

      end
        try
            numFrames = size(data{1,1},1)/channels;
            if max_number_of_frames~=0
                numFrames = min(numFrames,max_number_of_frames);
            end
            channelImg{1} = cell(1,numFrames); % for now just sigle channel
            for i=1:length(channelImg{1})
                channelImg{1}{i} = double(data{1,1}{1+channels*(i-1),1});
            end
            [f1,f2,fend] = fileparts(filename);
            names{end+1} = f2; 
        catch
        end

end

