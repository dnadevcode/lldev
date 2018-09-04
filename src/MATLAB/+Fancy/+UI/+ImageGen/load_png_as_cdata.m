function [] = load_png_as_cdata(gObj, srcFilepathPNG, fn_preprocess, fn_postprocess)
    % LOAD_PNG_AS_CDATA
    import Fancy.Utils.pass_through;
    import Fancy.UI.ImageGen.normalize_composite_alpha_inputs;
    import Fancy.UI.ImageGen.composite_alpha;
    
    if (nargin < 3) || isempty(fn_preprocess)
        fn_preprocess = @pass_through;
    end
    if (nargin < 4) || isempty(fn_postprocess)
        fn_postprocess = @pass_through;
    end
    
    [fgRGB, ~, fgAlpha] = imread(srcFilepathPNG);
    bgRGB = get(gObj, 'BackgroundColor');
    bgRGB = permute(bgRGB(:), [2 3 1]);
    bgAlpha = 1;
    [fgRGB, fgAlpha, bgRGB, bgAlpha] = normalize_composite_alpha_inputs(fgRGB, fgAlpha, bgRGB, bgAlpha);
    [fgRGB, fgAlpha, bgRGB, bgAlpha] = fn_preprocess(fgRGB, fgAlpha, bgRGB, bgAlpha);
    [compositeRGB, compositeAlpha] = composite_alpha(fgRGB, fgAlpha, bgRGB, bgAlpha);
    [compositeRGB, compositeAlpha] = fn_postprocess(compositeRGB, compositeAlpha);
    set(gObj, 'CData', compositeRGB);
end

