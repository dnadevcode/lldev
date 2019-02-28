# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
