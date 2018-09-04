function [] = export_theory_curve_tsvs(theoryCurves, theoryNames, tsvFilepaths)
    % Save theory barcodes as tsvs

    import Fancy.IO.TSV.write_tsv;
    numTheories = length(theoryCurves);
    for theoryNum = 1:numTheories
        tsvFilepath = tsvFilepaths{theoryNum};
        if isempty(tsvFilepath)
            continue;
        end
        theoryName = theoryNames{theoryNum};
        theoryCurve = theoryCurves{theoryNum};

        write_tsv(tsvFilepath, struct(matlab.lang.makeValidName(theoryName), theoryCurve(:)));
    end
end