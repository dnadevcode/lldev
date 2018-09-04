classdef GrayscaleMovieStorageMode
    % Helper Enumeration Class for GrayscaleMovie
   enumeration
        % GrayscaleMovieStorageMode:
        %   Raw: store original data in RawDataArr as non-negative integers
        %           (e.g. photon counts)
        %   RawApprox: 
        %   Nrm: store accurate data in NrmDataArr as doubles in the range
        %            [GrayscaleMovie.NrmMin, GrayscaleMovie.NrmMax]
        %           mapping linearly to the range
        %            [NrmMinRawVal, NrmMaxRawVal]
        %           in the RawDataArr
       RawPure,
       RawApprox,
       Normalized
   end
   methods
      function tf = is_pure_raw_mode(gmsm)
         import Microscopy.GrayscaleMovieStorageMode;
         tf = (GrayscaleMovieStorageMode.RawPure == gmsm);
      end
      function tf = is_approx_raw_mode(gmsm)
         import Microscopy.GrayscaleMovieStorageMode;
         tf = (GrayscaleMovieStorageMode.RawApprox == gmsm);
      end
      function tf = is_raw_mode(gmsm) %raw or raw approx
         tf = gmsm.is_pure_raw_mode() || gmsm.is_approx_raw_mode();
      end
      function tf = is_normalized_mode(gmsm)
         import Microscopy.GrayscaleMovieStorageMode;
         tf = (GrayscaleMovieStorageMode.Normalized == gmsm);
      end
   end
   methods (Static)
       function gmsm = get_default_storage_mode()
            import Microscopy.GrayscaleMovieStorageMode;
           gmsm = GrayscaleMovieStorageMode.RawPure;
       end
   end
end