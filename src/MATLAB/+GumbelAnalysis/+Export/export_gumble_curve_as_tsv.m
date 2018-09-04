function [] = export_gumble_curve_as_tsv(tsvFilepath, gumbelCurveX, gumbelCurveY)
    import Fancy.IO.TSV.write_tsv;

    gumbelCurveDataStruct.gumbelCurveX = gumbelCurveX;
    gumbelCurveDataStruct.gumbelCurveY = gumbelCurveY;
    write_tsv(tsvFilepath, gumbelCurveDataStruct, fields(gumbelCurveDataStruct));
end