classdef MicCamConfig < handle
    %MICCAMCONFIG - Microscope/Camera Configuration
    
    properties
        PixelWidth
        PointSpreadFunctionWidthNms
        FrameExposureLenSecs
        FrameDelayLenSecs
    end
    
    properties(SetAccess = private)
        PixelWidthUnit = Barcoding.LenUnits.Nanometers;
        PointSpreadFunctionWidthUnit = Barcoding.LenUnits.Nanometers;
    end
    
    properties (Dependent = true, SetAccess = private)
        FramesPerSecond
    end
    
    methods
        
        function [framesPerSecond] = get.FramesPerSecond(mcc)
            frameExposureLenSecs = mcc.FrameExposureLenSecs;
            frameDelayLenSecs = mcc.FrameDelayLenSecs;
            framesPerSecond = 1/(frameExposureLenSecs + frameDelayLenSecs); 
        end
          
        function [mcc] = MicCamConfig(pixelWidthNms, pointSpreadFunctionWidthNms, frameExposureLenSecs, frameDelayLenSecs)
            
            % From Supplemental material for
            % doi:10.1103/PhysRevE.92.062701
            % V. Iarko, E. Werner, L. K. Nyberg, V. Müller, J. Fritzsche,
            %  T. Ambjörnsson, J. P. Beech, J. O. Tegenfeldt, K. Mehlig,
            %  F. Westerlund, and B. Mehlig, Phys. Rev. E 92, 062701 (2015).
            % Extension of nano-confined DNA: quantitative comparison
            % between experiment and theory
            %
            % "Videos were recorded using a Photometrics EvolveTM EMCCD
            % camera. The image pixel size is 159.2 nm. For all
            % measurements, the exposure time was 100 ms per photograph,
            % but the delay between frames differed between experiments.
            % For experiment 1, the delay between frames was 84 ms,
            % yielding a framerate of 184 ms/frame. For experiments 2-3
            % with T4-DNA, the correlation time is significantly longer,
            % so to minimise problems with photo bleaching and nicking,
            % the framerate was decreased.
            % For experiment 2, the frame-rate was 0.5 s/frame for the
            % measurements at 0.05xTBE, and 2 s/frame for the ones at
            % 2xTBE.
            % For experiment 3, the frame-rate was 1 s/frame for all
            % measurements."
            %
            % http://journals.aps.org/pre/abstract/10.1103/PhysRevE.92.062701
            % http://arxiv.org/pdf/1506.02241.pdf
            DEFAULT_PIXEL_WIDTH_NM = 159.2; % doi:10.1103/PhysRevE.92.062701
            
            % DEFAULT_FRAME_EXPOSURES_SECONDS = 0.100;  % doi:10.1103/PhysRevE.92.062701 Experiments 1-3
            % DEFAULT_FRAME_DELAY_SECONDS = 0.084;  % doi:10.1103/PhysRevE.92.062701 Experiment 1: 5.4348 fps
            % DEFAULT_FRAME_DELAY_SECONDS = 0.400;  % doi:10.1103/PhysRevE.92.062701 Experiment 2: 2.0 fps
            % DEFAULT_FRAME_DELAY_SECONDS = 1.900;  % doi:10.1103/PhysRevE.92.062701 Experiment 3: 0.5 fps
            DEFAULT_FRAME_EXPOSURE_LEN_SECS = NaN;
            DEFAULT_FRAME_DELAY_LEN_SECS = NaN;
            
            
            % doi:10.1016/j.bbrc.2011.11.128
            % Nyberg LK, Persson F, Berg J, Bergström J, Fransson E,
            %  Olsson L, Persson M, Stålnacke A, Wigenius J, Tegenfeldt JO .
            % A single-step competitive binding assay for mapping of single
            % DNA molecules. Biochem. Biophys. Res. Commun. 2012;417:404-408.
            %
            % "The microscope used is a Zeiss Axiovision equipped with a
            % Photometrics Evolve EMCCD camera and a 100x oil immersion
            % objective (NA = 1.46) from Zeiss... The PSF was estimated by
            % fitting a Gaussian profile to the intensity profile of a
            % quantum dot imaged using the... microscope. A standard
            % deviation of approximately 0.3 ?m was obtained."
            %
            % http://www.ncbi.nlm.nih.gov/pubmed/22166208
            % http://www.sciencedirect.com/science/article/pii/S0006291X11021565

            DEFAULT_POINT_SPREAD_FUNCTION_WIDTH_NM = 300; % doi:10.1016/j.bbrc.2011.11.128
            
            % Objective
            %  Immersion: Oil
            %  Magnification: 100x
            %  Numerical Aperture: 1.46
            %  Brand: Zeiss
            
            if nargin < 1
                pixelWidthNms = DEFAULT_PIXEL_WIDTH_NM;
            else
                validateattributes(pixelWidthNms, {'double'}, {'scalar', 'nonnan', 'positive'}, 1);
            end
            
            if nargin < 2
                pointSpreadFunctionWidthNms = DEFAULT_POINT_SPREAD_FUNCTION_WIDTH_NM;
            else
                validateattributes(pointSpreadFunctionWidthNms, {'double'}, {'scalar', 'nonnan', 'positive'}, 2);
            end
            
            if nargin < 3
                frameExposureLenSecs = DEFAULT_FRAME_EXPOSURE_LEN_SECS;
            else
                validateattributes(frameExposureLenSecs, {'double'}, {'scalar', 'nonnan', 'positive'}, 3);
            end
            
            if nargin < 4
                frameDelayLenSecs = DEFAULT_FRAME_DELAY_LEN_SECS;
            else
                validateattributes(frameDelayLenSecs, {'double'}, {'scalar', 'nonnan', 'nonnegative'}, 4);
            end
            
            mcc.PixelWidth = pixelWidthNms;
            mcc.PointSpreadFunctionWidthNms = pointSpreadFunctionWidthNms;
            mcc.FrameExposureLenSecs = frameExposureLenSecs;
            mcc.FrameDelayLenSecs = frameDelayLenSecs;
        end
    end
    
end

