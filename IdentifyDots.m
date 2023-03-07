%do the identification based on the detected dots 
%use the images in path1 as reference (database) and images in path2 as unknown for identification


clear all
%load directories
% Get a list of all files and folders in this folder.
path1 = 'data\train';
path2 = 'data\test';
%dots setting
minNbrDots = 3;
shiftx = 50;
shifty = 50;
scale = 0.2;
files1 = dir(path1);
files2 = dir(path2);
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
	coor1 = dlmread(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\coor-dotsBest.txt'));
    %check number of dots            
    if size(coor1,1)>= minNbrDots
        %get first image from the folder            
        for kk = 3 : length(subFolders2)
            kk
            distall = 1000;
            %load dots                    
            set2 = dlmread(strcat(path2,'\',subFolders2(kk).name,'\roi',subFolders2(kk).name,'\coor-dotsBest.txt'));
            %check number of dots  
            set1 = coor1;
            if size(set2,1)>= minNbrDots
                if (size(set2,1)/size(set1,1) > 0.46 && size(set2,1)/size(set1,1) < 2.17) 
                %s1 = mean(set1);
                %s2 = mean(set2);
                %set2 = set2 - s2;
                %set1 = set1 - s1;
                ds = zeros(size(set1,1),1);
                if (size(set1,1) < size(set2,1))
                    if (size(set1,1)<6)
                        half = size(set1,1);
                    else
                    half = round(size(set1,1)/4*3); 
                    end
                else
                    if (size(set2,1)<6)
                        half = size(set2,1);
                    else
                        half = round(size(set2,1)/4*3); 
                    end
                end
                for (kt=-shiftx:5:shiftx)
                %    for (kt=40:5:shiftx)
                    for (l=-shifty:5:shifty)
                   %     for (l=30:5:shifty)
                        for (m =  -scale:0.05:scale)
                           % for (m =  -scale:0.05:0)
                            set2t = (set2 *(1+m)) + [kt l 0];
                            for (i=1:size(set1,1))                
                                dist = sqrt((set2t(:,1) - set1(i,1)).^2 + (set2t(:,2) - set1(i,2)).^2);
                                [u,v] = min(dist);
                                ds(i) = dist(v);
                            end
                            [u,v] = sort(ds);
                            distt = mean(u(1:half));
                            if (distt < distall)
                                distall = distt;     
                                ut = u;
                            end
                        end
                    end    
                end
                end
            end 
            sim(k-2,kk-2) = distall;  
        end  
    else
        sim(k-2,:) = 1000;  
    end
end









