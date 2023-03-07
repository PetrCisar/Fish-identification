%do the identification based HOG
%use the images in path1 as reference (database) and images in path2 as unknown for identification


clear all
%load directories
% Get a list of all files and folders in this folder.
path1 = 'data\train';
path2 = 'data\test';
files1 = dir(path1);
files2 = dir(path2);
%HOG settings
ofx = 15;
ofy = 15;
resizeX = 64;
resizeY = 64;
cellsize = 4;
% Get a logical vector that tells which is a directory.
dirFlags1 = [files1.isdir];
dirFlags2 = [files2.isdir];
% Extract only those that are directories.
subFolders1 = files1(dirFlags1);
subFolders2 = files2(dirFlags2);
%create matrix for similarity
sim1 = zeros(size(subFolders1,1)-2,size(subFolders1,1)-2);
% loop throught subfolders
for k = 3 : length(subFolders1)
    k
	%get first image from the folder
    filesI = dir(strcat(path1,'\',subFolders1(k).name,'\*.png')); 
    
    %loop throug all files and measure the distance
    
    for kk = 3 : length(subFolders2)
        tic
        distall = 1000;
        for II1 = 1:size(filesI,1)
            I1 = imread(strcat(path1,'\',subFolders1(k).name,'\',filesI(II1).name));   
            I1 = rgb2gray(I1);
            I1 = imresize(I1,[resizeY resizeX]);
            [h1,v1] = extractHOGFeatures(I1(ofy:end-ofy,ofx:end-ofx),'CellSize',[cellsize cellsize]);

            %get first image from the folder
            filesII = dir(strcat(path2,'\',subFolders2(kk).name,'\*.png'));

            for II2 = 1:size(filesII,1)
                %I2 = imread(strcat(path2,'\',subFolders2(kk).name,'\',filesII(II2).name));
                %I2 = rgb2gray(I2);
                %I2 = imresize(I2,[resizeY resizeX]);
                %I2 = rgb2hsv(I2);
                %I2 = I2(:,:,2);
                dist = 1000;
                for x=1:2:ofx*2-1
                    for y=1:2:ofy*2-1
                        load(strcat(path2,'\',subFolders2(kk).name,'\',num2str(II2),'-',num2str(x),'-',num2str(y),'.mat'));
                        d= norm(h1-h2);
                        if (d<dist)
                            dist = d;
                        end
                    end
                end                        
                if (dist<distall)
                    distall = dist;
                end
            end
        end
        sim(k-2,kk-2) = distall;
        toc
    end
    
end


