function [aborted, zeroModelFft, zeroModelKbpsPerPixel] = prompt_pregen_zero_model()
    [zeroModelFilename, dirpath] = uigetfile({'*.mat;'}, 'Zero-model fft selection', 'MultiSelect', 'off');
    aborted = isequal(dirpath, 0);
    if aborted
        zeroModelFft = [];
        zeroModelKbpsPerPixel = [];
        return;
    end
    zeroModelFilepath = fullfile(dirpath, zeroModelFilename);
    zeroModelStruct = load(zeroModelFilepath, 'kbpPerPixel', 'meanFFT');
    aborted = not(isfield(zeroModelStruct, 'kbpPerPixel')) || not(isfield(zeroModelStruct, 'meanFFT'));
    zeroModelFft = zeroModelStruct.meanFFT;
    zeroModelKbpsPerPixel = zeroModelStruct.kbpPerPixel;
end