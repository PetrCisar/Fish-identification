# Fish-identification
The code for individual fish identification based on HOG features and dots pattern
The code is written in Matlab

The code is available with testing data in data folder
data\train contains two directories with fish images  as reference database. The name of directrorz represent PIT tag number (unique identifier of the fish)
data\test contains two directories with fish images as uknown fish for identification. The name of directrorz represent PIT tag number (unique identifier of the fish)

Run order
1 - SegmentationROI.m  - it read all images, detect the fish object and extract the ROI containing the pattern

a2 - detectDotsOnRoi1000.m  - detects the dots in extracted ROI using CNN 
a3 - findStrongPoints.m  - filter out the unstable dots 
a4 - IdentifyDots.m  - do the identification of the images in data\test into the clases in data\train based on the dot positions

b2 - CalculateHOGsOnRoi1000.m - calcualte HOG features from exracted ROI
b3 - IdentifyHOG.m - do the identification of the images in data\test into the clases in data\train based on the HOGs
