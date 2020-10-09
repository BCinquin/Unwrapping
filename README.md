# Unwrapping grooves

ProfilMaker.ijm
a piece of code (Macro ImageJ) to Make the profile of a z stack file

You can find the sample here with an intermediary
https://zenodo.org/record/4075114#.X4BRPGgzbIU



ProfilMaker user a binarized resliced 3D data stack to find the profil of the shape
For each slice, a vertical line is drawn, intensity is found. Reading the values, the first and last coordinates with an intensity =! 0 are averaged. The coordinate is used to drawn the profil.

This way doesn't insure a continuity in the profil
When there is no max and min, the profil value is the average between the ones before and after

An additional smoothing is performed as well


The intent is to use this file to compute the slopes and project the information 

An indication on how to perform this is given by using an Area to Line function of ImageJ

unwrap 3D data to a 2D map
