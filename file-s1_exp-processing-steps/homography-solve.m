%% Undistort images
load('gopro-calibration-matrix.mat'); %loads camera intrinsic parameters
%load('GoProCalibrationMatrix_GP2_Florian.mat'); %this calibration is based
%on Florian's GoPro but it is not as good
%(c) Derek Leung 2020
%Submitted as a supplementary material for MScR GeoSciences

% Prompts user for file and directory
processIm = imgetfile('MultiSelect', true);
[filepath,name,ext] = fileparts(processIm{1});
outputDir = uigetdir(filepath, 'Specify target directory');
name = input('file name ', 's');

for i = 1:length(processIm)
    filename = sprintf('%s%s%s%04d.tiff',outputDir,'\',name,i-1);
    undistortCalib = undistortFisheyeImage(imread(processIm{i}), cameraParams.Intrinsics, 'OutputView', 'Full');
    imwrite(undistortCalib, filename, 'tiff');  
end 

%% Calculate the projection based on a photo with a checkerboard. 
%  Note that this checkerboard should be undistorted
boardSize = [10 13];
squareSize = 20;
[worldpoints] = generateCheckerboardPoints(boardSize, squareSize)

checkerboardImage = imgetfile('MultiSelect', false);

[checkerboardMatrix,boardSizeCheck] = detectCheckerboardPoints(checkerboardImage);
tform = fitgeotrans(checkerboardMatrix, worldpoints, 'projective');

%% transforms the projection of one image (the checkerboard one) but doesn't save

oldImage = imread(checkerboardImage);
newImage = imwarp(oldImage, tform);
imtool(newImage)

%% transforms a set of images to orthographic based on the reference checkerboard image
% INPUT UNDISTORTED IMAGES
processIm = imgetfile('MultiSelect', true);
[filepath,name,ext] = fileparts(processIm{1});
outputDir = uigetdir(filepath, 'Specify target directory');
name = input('file name ', 's');

for i = 1:length(processIm)
    
    oldImage = imread(processIm{i});
    newImage = padarray(rot90(padarray(imwarp(oldImage, tform), 300, 'both')), 300, 'both');
    %imtool(newImage)
    
    filename = sprintf('%s%s%s%04d.tiff',outputDir,'\',name,i-1);
    imwrite(newImage, filename, 'tiff');
    
end 

%% projection of checkerboards to check errors
% Prompts user for file and directory
processIm = imgetfile('MultiSelect', true);
%[filepath,name,ext] = fileparts(processIm{1});
%outputDir = uigetdir(filepath, 'Specify target directory');
%name = input('file name ', 's');
m = worldpoints;

for i = 1:length(processIm)
    
    [checkerboardMatrix,boardSizeCheck] = detectCheckerboardPoints(processIm{i});
    m = [m; NaN NaN; checkerboardMatrix];
end 

writematrix(m, 'Checkerboard_points.xls');