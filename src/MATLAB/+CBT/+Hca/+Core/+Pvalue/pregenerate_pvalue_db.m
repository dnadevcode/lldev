function [] = pregenerate_pvalue_db(file, path, params)

if nargin < 2
    [file,path] = uigetfile({'*.txt'},'load pre-computed p-value file');
end

if nargin < 3
    import CBT.Hca.Import.set_pval_params;
	[ params ] = set_pval_params( );
end

%% METHOD 1. This method is based on maximum distribution. See method1.tex 
% for details on this method

% choose timeframes nr for unfiltered kymographs
fullPath = strcat([path,file]);

try addpath(genpath(path));
catch
	warning('no session file provided');
    rS = 'presultNew.txt';
    fid = fopen(rS,'w');
    fclose(fid);
    fullPath = strcat([pwd '/' rS]);
end
try
    import CBT.Hca.Import.load_pval_struct;
    [ vals, data ] = load_pval_struct(fullPath);
catch
    error('unloadable session file. Try a different session file');
end
          
import CBT.Hca.Core.Pvalue.precompute_pvalue_files;
precompute_pvalue_files(fullPath, params );

end

