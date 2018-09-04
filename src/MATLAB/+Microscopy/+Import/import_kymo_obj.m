function kymoObj = import_kymo_obj(srcKymoFilepath)
    s = load(srcKymoFilepath, 'kymoObj');
    kymoObj = s.kymoObj;
end