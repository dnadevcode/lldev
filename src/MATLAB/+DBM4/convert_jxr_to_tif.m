function [newNames ] = convert_jxr_to_tif(data)

% % https://www.xnview.com/en/nconvert/#downloads
% 'https://download.xnview.com/NConvert-linux64.tgz'
% 
% 

nconvertmatloaded = exist('nconvert', 'file') == 2;


% 
% 
    mFilePath = mfilename('fullpath');
    dataCatcheFold = fileparts(fileparts(fileparts(fileparts(mFilePath))));
% % download and un-zip nconvert
if nconvertmatloaded == 0  
    % % First check if the selected tool (bfopen) is loaded:

    if ismac
        file = 'https://download.xnview.com/NConvert-macosx64.tgz';
    elseif ispc
        file = 'https://download.xnview.com/NConvert-win64.zip';
    else
        file = 'https://download.xnview.com/NConvert-linux64.tgz';
    end
    [~,~,sep]= fileparts(file);
    websave(fullfile(dataCatcheFold,'DataCache',['NConvert',sep]),file);
    if ispc
        unzip(fullfile(dataCatcheFold,'DataCache',['NConvert',sep]),fullfile(dataCatcheFold,'DataCache'));
    else
        untar(fullfile(dataCatcheFold,'DataCache',['NConvert',sep]),fullfile(dataCatcheFold,'DataCache'));
    end
       
    addpath(genpath(fullfile(dataCatcheFold,'DataCache')));

   if ispc
        nconvertmatloaded = exist('nconvert.exe', 'file') == 2;
   else
        nconvertmatloaded = exist('nconvert', 'file') == 2;
   end
end

if nconvertmatloaded == 0
    error('Failed to load nconvertmatloaded, please download from https://download.xnview.com and unzip to DataCache folder');
end


if nargin < 1
    data =[];
end
%

if isempty(data)
    data = dir(fullfile(uigetdir(),'*.jxr'));
else
    data = dir(data);
end


newNames = [];
newInfo = [];

for i=1:length(data)
    disp(strcat(['Converting movie ' num2str(i) ' from ' num2str(length(data)) ]))
    name =fullfile(data(i).folder,data(i).name);
    [fd,fm,fe] = fileparts(name);
    nameNew = strrep(name,fe,'.tiff');
%     nameNew2 = strrep(name,fe,'.ini');
    
    if exist(nameNew,'file')
        delete(nameNew); % in case already exists tif, remove 
    end
    command = strcat([fullfile(dataCatcheFold,'DataCache','NConvert','nconvert')  ' -out tiff -org_depth -c 0 -q 100 -o "' nameNew '" "' name '"']);

%     command = strcat([fullfile(dataCatcheFold,'DataCache','NConvert','nconvert')  ' -org_depth -c 0 -q 100 -out tiff "'  name '" ']);
    [a1,b1] = system(command);
    newNames{i} = nameNew;
end

end

