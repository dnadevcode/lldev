function [outpath] = default_output_path(path)
      mFilePath = mfilename('fullpath');
            mfolders = split(mFilePath, {'\', '/'});
       outpath = fullfile(mfolders{1:end-5},'OutputFiles',path);
end

