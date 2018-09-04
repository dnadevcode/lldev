If you do not have a copy of dcraw in your bin directory, importing DNGs will not work.
Since we want to avoid having binary files in the git repository, this means that the standard way to get dcraw is to compile it yourself.

To do this, you must have gcc installed if it is not already installed (it usually is)

The gcc command must also be accessible to run with the system command via Matlab (e.g. in a directory within your $PATH environment variable) if it is not already there (it usually is)

Afterwards, the first time you try to import a dng, bind\dcraw should theoretically be automatically compiled when the import_dng function does the following:
 ensures that the following script is executable (via chmod u+x) and then runs it
  src\sh\linux_compile_dcraw.sh
