function [successTF, settings] = get_valid_settings(settings)
    if nargin < 1
        settings = struct();
    end

    successTF = false;

    if not(isfield(settings, 'consensus'))
        settings.consensus = struct();
    end
    if not(isfield(settings.consensus, 'clusterScoreThresholdNormalized'))
        settings.consensus.clusterScoreThresholdNormalized = [];
    end
    if not(isfield(settings.consensus, 'defaults'))
        settings.consensus.defaults = [];
    end
    if not(isfield(settings, 'dbm'))
        settings.dbm = [];
    end
    if isempty(settings.consensus.defaults) || isempty(settings.dbm)
        import OldDBM.General.SettingsWrapper;
        if not(isfield(settings, 'dbmParamsIniFilepath'))
            settings.dbmParamsIniFilepath = [];
        end
        if isempty(settings.dbmParamsIniFilepath)
            settings.dbmParamsIniFilepath = SettingsWrapper.get_default_DBM_ini_filepath();
        elseif not(exist(settings.dbmParamsIniFilepath, 'file'))
            settings.dbmParamsIniFilepath = SettingsWrapper.prompt_DBM_ini_filepath(defaultSettingsFilepath);
        end
        if isempty(settings.dbmParamsIniFilepath)
            return;
        end
        import CBT.Consensus.Import.get_default_consensus_settings;
        [settings.consensus.defaults, settings.dbm] = get_default_consensus_settings(settings.dbmParamsIniFilepath);
    end
    if isempty(settings.dbm)
        return;
    end

    if not(isfield(settings.consensus, 'preprocessing'))
        settings.consensus.preprocessing = struct();
    end
    if not(isfield(settings.consensus.preprocessing, 'stretch'))
        settings.consensus.preprocessing.stretch = struct();
    end
    if not(isfield(settings.consensus.preprocessing.stretch, 'untrustedEdgeLenUnrounded_pixels'))
        settings.consensus.preprocessing.stretch.untrustedEdgeLenUnrounded_pixels = [];
    end
    if not(isfield(settings.consensus.preprocessing.stretch, 'pixelWidth_nm'))
        settings.consensus.preprocessing.stretch.pixelWidth_nm = [];
    end
    if isempty(settings.consensus.preprocessing.stretch.untrustedEdgeLenUnrounded_pixels) || isempty(settings.consensus.preprocessing.stretch.pixelWidth_nm)
        import CBT.Consensus.Import.get_prestretch_params;
        [prestretchUntrustedEdgeLenUnrounded_pixels, prestretchPixelWidth_nm] = get_prestretch_params(settings.dbm);
        settings.consensus.preprocessing.stretch.untrustedEdgeLenUnrounded_pixels = prestretchUntrustedEdgeLenUnrounded_pixels;
        settings.consensus.preprocessing.stretch.pixelWidth_nm = prestretchPixelWidth_nm;
    end


    if isempty(settings.consensus.clusterScoreThresholdNormalized)
        if isempty(settings.consensus.defaults)
            return;
        end
        import CBT.Consensus.Import.get_cluster_threshold;
        settings.consensus.clusterScoreThresholdNormalized = get_cluster_threshold(settings.consensus.defaults);
    end
    if isempty(settings.consensus.clusterScoreThresholdNormalized)
        return;
    end

    if not(isfield(settings, 'preprocessing'))
        settings.preprocessing = struct();
    end
    if not(isfield(settings.preprocessing, 'foregroundMasking'))
        settings.preprocessing.foregroundMasking = struct();
    end
    if not(isfield(settings.preprocessing.foregroundMasking, 'maxAmpDist'))
        settings.preprocessing.foregroundMasking.maxAmpDist = [];
    end
    if isempty(settings.preprocessing.foregroundMasking.maxAmpDist)
        settings.preprocessing.foregroundMasking.maxAmpDist = 2;
    end

    if not(isfield(settings.preprocessing, 'rotation'))
        settings.preprocessing.rotation = struct();
    end
    if not(isfield(settings.preprocessing.rotation, 'numAngleCandidates'))
        settings.preprocessing.rotation.numAngleCandidates = [];
    end
    if isempty(settings.preprocessing.rotation.numAngleCandidates)
        settings.preprocessing.rotation.numAngleCandidates = 60; % 180/60=3 degree intervals
    end
    if not(isfield(settings.preprocessing.rotation, 'angleOffset'))
        settings.preprocessing.rotation.angleOffset = [];
    end
    if isempty(settings.preprocessing.rotation.angleOffset)
        settings.preprocessing.rotation.angleOffset = 0;
    end
    if not(isfield(settings.preprocessing, 'kymoEdgeDetection'))
        settings.preprocessing.kymoEdgeDetection = struct();
    end
    if not(isfield(settings.preprocessing.kymoEdgeDetection, 'morphExpansion'))
        settings.preprocessing.kymoEdgeDetection.morphExpansion = [];
    end
    if isempty(settings.preprocessing.kymoEdgeDetection.morphExpansion)
        settings.preprocessing.kymoEdgeDetection.morphExpansion = 5;
    end
    if not(isfield(settings.preprocessing.kymoEdgeDetection, 'morphShrinking'))
        settings.preprocessing.kymoEdgeDetection.morphShrinking = [];
    end
    if isempty(settings.preprocessing.kymoEdgeDetection.morphShrinking)
        settings.preprocessing.kymoEdgeDetection.morphShrinking = 3;
    end

    successTF = true;
end