function [croppingDetails] = select_image_region_prompt(dispImg, hPanel)
    import Microscopy.UI.RegionSelection.select_image_region_prompt_async;

    hButtonContinue = [];
    croppingDetails = [];
    
    function onCompleteCallback(croppingDetailsOutput)
        croppingDetails = croppingDetailsOutput;
        delete(hButtonContinue);
    end
    hButtonContinue = select_image_region_prompt_async(dispImg, hPanel, @onCompleteCallback);
    waitfor(hButtonContinue);
end