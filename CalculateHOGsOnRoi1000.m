% code to calculate HOG features from detected ROI on the fish 
% the code reads all images from selected folder and calculate HOGs 
% the outcome are the files with HOG features


clear all
%load directories
% Get a list of all files and folders in this folder.
path1 = 'data\train';
files1 = dir(path1);
%HOG settings
ofx = 15;
ofy = 15;
resizeX = 64;
resizeY = 64;
cellsize = 4;
% Get a logical vector that tells which is a directory.
dirFlags1 = [files1.isdir];
% Extract only those that are directories.
subFolders1 = files1(dirFlags1);
% loop throught subfolders
for k = 3 : length(subFolders1)
    k
	%get first image from the folder
    filesI = dir(strcat(path1,'\',subFolders1(k).name,'\*.png')); 
    
    for II1 = 1:size(filesI,1)
            I1 = imread(strcat(path1,'\',subFolders1(k).name,'\',filesI(II1).name));   
            I1 = rgb2gray(I1);
            I1 = imresize(I1,[resizeY resizeX]);
            for x=1:2:ofx*2-1
                for y=1:2:ofy*2-1
                    [h2,v2] = extractHOGFeatures(I1(y:end-ofy*2+y-1,x:end-ofx*2+x-1),'CellSize',[cellsize cellsize]);
                    save(strcat(path1,'\',subFolders1(k).name,'\',num2str(II1),'-',num2str(x),'-',num2str(y),'.mat'),'h2');
                end
            end                    
            
    end
    
end