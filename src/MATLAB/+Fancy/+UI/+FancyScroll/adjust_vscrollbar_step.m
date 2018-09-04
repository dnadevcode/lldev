function adjust_vscrollbar_step(hSlider, contentViewportRatio)
    sliderStep = get(hSlider, 'SliderStep');
    sliderStep(2) = max(1.0/max(contentViewportRatio - 1.0, 0), sliderStep(1));
    set(hSlider, 'SliderStep', sliderStep);
end