# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.4.2] - 2020-10-07
- Added a tool for tif/png classification, which can be run
Microscopy.UI.UserSelection.goodbadtool()
## [0.4.1] - 2020-05-04
- Now possible to run DBM_GUI by using two methods" 'old', and 'corr'
- both method can be run without clicking anything on GUI by DBM_GUI(0)
- Added possibility of including edge molecules to DBM 
- CBC GUI fixed that marked molecules would be unmarked again after generating something, and
that generated data was not saved so it had to be recalculated again

## [0.4.0] - 2020-03-23
- Rewrote the DBM_GUI so that all the important settings are imported via
SettingFiles/DBM.ini file
## [0.3.8] - 2019-12-10
- Fixed the filter settings check so that it would se
## [0/3/7] - 2019-11-03
- Fixed experimental consensus import in CBT, so that many can be imported at the same time
- Fixed name error in SVD so that mex functions could be compiled
## [0.3.6] - 2019-09-25
- Fixed a bug in find molecule position, that ignored all molecules rather close to edges
## [0.3.4] - 2019-06-17
- Fixed a bug with one AB source file that was in the wrong directory
## [0.3.2] - 2019-02-28
- Added support to AB gui to extract too long fragments
## [0.3.1] - 2019-02-27
- Some bugfixes, added some documentation codes, 
- Remove HCA since it's in separate repository
- AB is updated, but should be removed from later version (and put in separate directory)
- ELD is updated, but should be removed, since we'll have it in separate repository

## [0.3.0] - 2018-10-17
### Updates
- Updated dot-labelled barcodes code in ELD (developed separately)
- Updated HCA to the newest version (developed separately)


## [0.2.4] - 2018-08-27
- Fix molecule detection in DBM, because there were some edge cased when it failed

## [0.2.3] - 2018-04-02
- Add HCA_Gui

## [0.2.2] - 2018-01-25

- ETE_Gui - Fix txt export 
- SVD_Gui - Add p-value comparison

## [0.2.1] - 2017-10-24

- MMT_Gui - fix a broken plotting tab
- CBC_Gui - fix an error message in exporting tsv files

## [0.2.0] - 2017-10-17

- Changed MMT_Gui so now it follows the standard coding style
- Updated ETE_Gui with generation of new null model and fixed bugs

## [0.1.2] - 2017-10-02

### Fixes

- CBC_Gui dissapearing items

## [0.1.1] - 2017-06-20
### Added
- CBC normalization options.
- New MMT GUI.
- HMM C/Matlab method added. Added to current SVD_Gui
- New CBT binding constants.
- Optional C functions for CBT theory generation.
- C/MEX functions can be compiled with the compile_mex.m script in src/C/

### Changes
- Default consensus normalization is set to zscore, previously no normalization.
- CBT quick script now prompts for CBT.ini settings file. 
- SVD_GuiNew renamed SVD_Gui.
- CBT basepair to pixel resolution function changed to a moving average rather than selected single basepairs.

### Removed
- Old SVD Gui removed. 

### Fixes
- CBC only prompts for cluster CC threshold once.
- CBC consensus export no longer throws an error when trying to print consensus filepath.
- CBC Tiff export works.
- CBT experimental tab opens properly.
- Fancy IO TSV writer fixed.
