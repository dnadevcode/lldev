function writeSuccess = try_write_file(writeFilepath, fileContentsStr)
    writeSuccess = false;
    fid = fopen(writeFilepath,'w');
    if fid ~= -1
        try
            fprintf(fid, '%s', fileContentsStr);
            writeSuccess = true;
        catch
        end
        fclose(fid);
    end
end