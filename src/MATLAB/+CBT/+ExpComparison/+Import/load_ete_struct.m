function [eteStruct, eteFilepath] = load_ete_struct(eteFilepath)
    if nargin < 1
        eteFilepath = [];
    end
    eteSessionStruct = [];
    import OptMap.DataImport.try_prompt_ete_filepaths;
    [~, eteFilepaths] = try_prompt_ete_filepaths([], false);
    if isempty(eteFilepaths)
        return;
    end
    eteFilepath = eteFilepaths{1};
    if isempty(eteFilepath)
        return;
    end
    eteStruct = load(eteFilepath, 'eteSessionStruct');
    if isfield(eteStruct, 'eteSessionStruct')
        eteStruct = eteStruct.eteSessionStruct;
    end
end