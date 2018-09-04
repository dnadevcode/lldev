If you do not have a copy of dcraw.exe in your bin directory, importing DNGs will not work.
Since we want to avoid having binary files in the git repository, this means that the standard way to get dcraw.exe is to compile it yourself.

To compile dcraw.exe from the source in src/C/ThirdParty/dcraw/dcraw.c, you can take the following steps:

1) Download mingw-get-setup.exe which can be found here:
https://sourceforge.net/projects/mingw/files/latest/download

2) Run the downloaded installer and follow the graphical interface prompts to complete the installation.

3) Add the bin directory that contains mingw-get.exe (e.g. "C:\MinGW\bin") to your system's Environment Variables.

To do this you can try the following:
Click Windows + R to open the run dialog
Then enter "rundll32 sysdm.cpl,EditEnvironmentVariables" without the quotes and press enter to open the "Environment Variable" window.
Click on the "PATH" entry in the TOP box, then click on the "Edit..." button
Then click on the "New" button
Enter the bin directory path (e.g. "C:\MinGW\bin") in the highlighted location
Click "OK" until all the windows are closed.

4) Install gcc through mingw

To do this you can try the following:
Click Windows + R to open the run dialog
Then enter "cmd" to open command prompt
Then in the command prompt enter "mingw-get install gcc"

5) Compile dcraw.c with gcc

first change the drive letter to whichever drive this directory is located, if that is not already the drive
e.g. if it is "c:\" run the following in the command prompt without the quotes:
"C:"

then change the directory to the directory containing this readme
e.g. if it is "C:\Users\Saair\Documents\MATLAB\LiteLjus\" run the following in the command prompt without the quotes:
"cd C:\Users\Saair\Documents\MATLAB\LiteLjus\"

then run the following to compile the program:

gcc -o bin/dcraw.exe -O3 src/C/ThirdParty/dcraw/dcraw.c -lm -DNODEPS