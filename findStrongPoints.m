%try to select only points presented on more than 2 images of the same fish
%read all images with detected dots from the directory
%only the dots present in more than 2 images are selected and their coordinates are stored in outpput file
%it is used to filter out incorectly detected dots

clear all
%load directories
% Get a list of all files and folders in this folder.
path1 = 'data\train';
files1 = dir(path1);
minNbrDotsNormal = 3;
minNbrDotsDec = 2;
nbrDotsMax = 100;
distMax = 20;
offsetX = 50;
offsetY = 30;
resizeto = 1000;

limitUP = 0;
limitBOTTOM = 1
% Get a logical vector that tells which is a directory.
dirFlags1 = [files1.isdir];
% Extract only those that are directories.
subFolders1 = files1(dirFlags1);
% loop throught subfolders
for k = 29 : length(subFolders1)
    k-2
	%get all images from the folder and compare them with the rest
    filesI = dir(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\*.png'));                       
    distall = 1000;    
    %read all coordinates 
    for II1 = 1:size(filesI,1)                    
        tempc = dlmread(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(II1).name(1:end-4),'-dotsCoorMovchan.txt'));            
        I1 = imread(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(II1).name));        
        I1 = imresize(I1, resizeto/size(I1,2));
        %remove point too close to the edges
        for cc = size(tempc,1):-1:1
            if (tempc(cc,2) > size(I1,1)*limitBOTTOM || tempc(cc,2) < size(I1,1)*limitUP)
                tempc(cc,:) = [];
            end
        end
        coor{II1} = tempc;
    end                
    %try to match the coordinates by movements    
    countPoints = 0;
    Xclose = -1;
    Yclose = -1;
    close = 1000;
    imageNbr = 0;
    for II = 1:size(filesI,1)
        coorRef = coor{II};
        if size(coorRef,1) < 7
            minNbrDots = minNbrDotsDec;
        else
            minNbrDots = minNbrDotsNormal;
        end
            
        for II1 = II+1:size(filesI,1)                               
            coort = coor{II1};
            for x=-offsetX:offsetX
                for y=-offsetY:offsetY        
                    if x==0 && y==0
                        dsfsd=1;
                    end
                    clear coortS;
                    SelPointsX = zeros(30,1);
                    SelPointsY = zeros(30,1);
                    DistPoint = zeros(30,1);
                    coortS(:,1) = coort(:,1) + x;
                    coortS(:,2) = coort(:,2) + y;
                    %find closest point to each point
                    countClose = 0;
                    distClose = 0;
                    for ii = 1:size(coorRef,1)
                        distpoint = 1000;
                        for iii = 1:size(coortS,1)
                            distpointT = sqrt((coorRef(ii,1)-coortS(iii,1))^2 + (coorRef(ii,2)-coortS(iii,2))^2);
                            if (distpointT < distMax && distpointT < distpoint)
                                distpoint = distpointT;                            
                            end
                        end
                        if (distpoint < 1000)
                            countClose = countClose + 1;
                            distClose = distClose + distpoint;
                            SelPointsX(countClose) = coorRef(ii,1);
                            SelPointsY(countClose) = coorRef(ii,2);
                            DistPoint(countClose) = distpoint;
                        end
                    end                
                    if (countClose > minNbrDots && countClose >= countPoints)
                        distClose = distClose / countClose;
                        if (distClose < close)
                            countPoints = countClose;
                            Xclose = x;
                            Yclose = y;
                            close = distClose;
                            SelPointsXF = SelPointsX;
                            SelPointsYF = SelPointsY;
                            DistPointF = DistPoint;
                            imageNbr = II;
                        end
                    end
                end
            end
        end
    end
    %save detected dots
    %select x dots only 
    %create subsets of all dots 
    temp = [SelPointsXF(1:countPoints) SelPointsYF(1:countPoints) DistPointF(1:countPoints)];
    [vv,is] = sort(temp(:,3));
    if nbrDotsMax>size(is,1)
        DotsrealNbr= size(is,1);
    else
        DotsrealNbr= nbrDotsMax;
    end   
    temp = temp(is(1:DotsrealNbr),:);
    %draw dots
    
    if (imageNbr > 0)
        I = imread(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(imageNbr).name));
        I = imresize(I, resizeto/size(I,2));
        for ifi = 1:size(temp,1)
            I(temp(ifi,2)-2:temp(ifi,2)+2,temp(ifi,1)-2:temp(ifi,1)+2,1)=0;
            I(temp(ifi,2)-2:temp(ifi,2)+2,temp(ifi,1)-2:temp(ifi,1)+2,2)=0;
            I(temp(ifi,2)-2:temp(ifi,2)+2,temp(ifi,1)-2:temp(ifi,1)+2,3)=255;
        end
        imwrite(I,strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\',filesI(imageNbr).name(1:end-4),'-repreImage.jpg'));
    end
    %save dots
    v = 1:size(temp,1);
    if (size(temp,1) == 0)
        dlmwrite(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\','coor-dotsBest.txt'),[0 0 0]);
    else
        %normalize size
        rf = resizeto / size(I,2);
        temp(:,1) = temp(:,1)*rf;        
        temp(:,2) = temp(:,2)*rf;
        dlmwrite(strcat(path1,'\',subFolders1(k).name,'\roi',subFolders1(k).name,'\','coor-dotsBest.txt'),[temp(:,1) temp(:,2) temp(:,3)]);
    end
    
end


