% code to detect the dots on fish skin 
%the code read all images from selected folder and detect the dots using CNN stored in DotsNetNew-Movchan.mat 
% the outcome are images with detected dots and the file with dots positions

clear all
warning off
%load directories
% Get a list of all files and folders in this folder.
path1 = 'data\train';
%load network
load DotsNetNew-Movchan;
files1 = dir(path1);
% Get a logical vector that tells which is a directory.
dirFlags1 = [files1.isdir];
% Extract only those that are directories.
subFolders1 = files1(dirFlags1);
resizeto = 1000;

% loop throught subfolders
for k =3 : length(subFolders1)
    k-2
    %get first image from the folder
    filesI = dir(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\*.png')); 
    
    %loop throug all files and measure the distance
    
                
        for II1 = 1:size(filesI,1)
            I = imread(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(II1).name));   
            I = imresize(I, resizeto/size(I,2));
            I1 = rgb2gray(I);
            xdot = 0;
            ydot = 0;
            probsel = 0;
            countdot = 0;
            %detect dots
            for x=1:10:size(I1,2)-50                
                for y=1:10:size(I1,1)-50
                    patch = I1(y:y+48,x:x+48,:);                    
                    %classify path
                    [Yc,prob] = classify(net,patch);
                    if (prob(1)>0.3) && x > 0.3*size(I,2) && y>0.05*size(I,1) 
                        countdot=countdot+1;
                        xdot(countdot) = x + 25;
                        ydot(countdot) = y + 25;   
                        probsel(countdot) = prob(1);
                    end
                end
            end          
            [clustersCentroids,clustersGeoMedians,clustersXY,clusters] = clusterXYpoints([xdot;ydot]',15,1); 
            %calculate the probability of clustered points
            probclus = zeros(size(clusters,1),1);
            for ic = 1:size(clusters,1)
                probclus(ic) = max(probsel(clusters{ic}));
            end
            %save detected dots
           
            dlmwrite(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(II1).name(1:end-4),'-dotsCoorMovchan.txt'),[clustersCentroids probclus]);
            %draw dots
            if size(clustersCentroids,1)>1                
                for ifi = 1:size(clustersCentroids,1)                
                    I(clustersCentroids(ifi,2)-2:clustersCentroids(ifi,2)+2,clustersCentroids(ifi,1)-2:clustersCentroids(ifi,1)+2,1)=255;
                    I(clustersCentroids(ifi,2)-2:clustersCentroids(ifi,2)+2,clustersCentroids(ifi,1)-2:clustersCentroids(ifi,1)+2,2)=0;
                    I(clustersCentroids(ifi,2)-2:clustersCentroids(ifi,2)+2,clustersCentroids(ifi,1)-2:clustersCentroids(ifi,1)+2,3)=0;
                end
            end
            imwrite(I,strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(II1).name(1:end-4),'-dots.jpg'));
        end           

end
