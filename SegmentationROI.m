% this is the first step for salmon data processing
%script for atlantic salmon data (fish in tent, out of water), we detected
%the largest object and segmented it (mask) fill the holes, rotate the
%object, find the ROI, drow red stars on a fish body for vizualization of
%the ROI (output). At the end we got the ROI (image with the region of
%interest). 

warning off
%read list of the files
path = 'data'; %data set folder
resizeFact = 6;
directories = dir(path);
for dirsN = 3:size(directories,1)

files = dir([path '\' directories(dirsN).name '\*.png']);
mkdir([path '\' directories(dirsN).name],['mask' directories(dirsN).name]);
mkdir([path '\' directories(dirsN).name],['output' directories(dirsN).name]);
mkdir([path '\' directories(dirsN).name],['roi' directories(dirsN).name]);

    for filesN= 1:size(files,1)

        filesN

        iorig = imread([path '\' directories(dirsN).name '\' files(filesN).name]);
        fin = dlmread([path '\' directories(dirsN).name '\upperfin'  directories(dirsN).name '\' files(filesN).name(1:end-4) '.txt']);
        i = imresize(iorig,1/resizeFact);
        ifin = zeros(size(iorig,1),size(iorig,2),1);
        ifin(fin(2)-1:fin(2)+1,fin(1)-1:fin(1)+1) = 1;
        
        %i = iorig;
        % recalculate RGB to HSV
        inewhsv= rgb2hsv(i);
        % threshold for 2 channels (Hue, Value)  
        % find the largest object (fish)
        object = inewhsv(:,:,1)<0.13;
        object = imerode(object,[1 1 1;1 1 1;1 1 1]);
%        object = maskbgr.*object;

        BWfish = bwlabel(object);
        objectinfo = regionprops(BWfish,'Area','BoundingBox');
        MaxSize = 0;
        id =0;
        for inew = 1:size(objectinfo,1)
            if objectinfo(inew).Area>MaxSize
                 if objectinfo(inew).BoundingBox(2)>1
                MaxSize = objectinfo(inew).Area;
                id=inew;
            end
            end
        end
        %fill the holes in an object
        ibobject =BWfish==id;
        ibobject = imclose(ibobject,strel('disk',6));
        ibobject = imfill(ibobject,'holes');
%         border = (ibobject - imerode(ibobject,strel('square',3)))*255;
%         i = double(i);
%         i(:,:,1) = i(:,:,1)+ border;
%         i(:,:,2) = i(:,:,2)+ border;
%         i(:,:,3) = i(:,:,3)+ border;
%         i = uint8(i);
%         imshow(i)
%         imwrite(i,[path directories(dirsN).name '\segmentation'  directories(dirsN).name '\' files(filesN).name(1:end-4) '.png']);
        imwrite(ibobject,[path '\' directories(dirsN).name '\mask'  directories(dirsN).name '\' files(filesN).name(1:end-4) '.png']);
        %rotation 
        mask = ibobject;
        maskinfo = regionprops(mask,'Orientation');
        iorig = imrotate(iorig, -maskinfo(1).Orientation);
        mask = imrotate(mask, -maskinfo(1).Orientation);
        ifin = imrotate(ifin, -maskinfo(1).Orientation);
        bb = regionprops(mask,'BoundingBox');
        
        %find the tail
        %find the maximal height part
        posMax = 0;
        heightMax = 0;              
        bb(1).BoundingBox = round(bb(1).BoundingBox);
        for x = round(bb(1).BoundingBox(1)+bb(1).BoundingBox(3)/8*7:bb(1).BoundingBox(1)+bb(1).BoundingBox(3))
            for y = bb(1).BoundingBox(2):bb(1).BoundingBox(2)+bb(1).BoundingBox(4)
                if mask(y,x)>0
                    top =round(y);
                    break;
                end
            end
            for y = bb(1).BoundingBox(2)+bb(1).BoundingBox(4):-1:bb(1).BoundingBox(2)
                if mask(y,x)>0
                    bottom =round(y);
                    break;
                end
            end
            if heightMax < bottom - top
                heightMax = bottom - top;
                posMax = x;
            end
        end
        %find the minimal height part on left from the maximal part
        posMin = 0;
        heightMin = 10000;              
        for x = round(bb(1).BoundingBox(1)+bb(1).BoundingBox(3)/4*3:posMax)
            for y = bb(1).BoundingBox(2):bb(1).BoundingBox(2)+bb(1).BoundingBox(4)
                if mask(y,x)>0
                    top =round(y);
                    break;
                end
            end
            for y = bb(1).BoundingBox(2)+bb(1).BoundingBox(4):-1:bb(1).BoundingBox(2)
                if mask(y,x)>0
                    bottom =round(y);
                    break;
                end
            end
            if heightMin >= bottom - top
                heightMin = bottom - top;
                posMin = x;
            end
        end
%         imshow(mask);
%         hold on
%         plot([posMin posMin], [1 size(mask,1)],'r');
%         hold off
%         drawnow
%      remove tail
        mask(:,posMin:end) = 0;
        maskinfo = regionprops(mask,'Orientation');
        iorig = imrotate(iorig, -maskinfo(1).Orientation);
        mask = imrotate(mask, -maskinfo(1).Orientation);
        ifin = imrotate(ifin, -maskinfo(1).Orientation);
        bb = regionprops(mask,'BoundingBox');
        mask = mask(bb(1).BoundingBox(2):bb(1).BoundingBox(2)+bb(1).BoundingBox(4),bb(1).BoundingBox(1):bb(1).BoundingBox(1)+bb(1).BoundingBox(3));
        iorig = iorig(bb(1).BoundingBox(2)*resizeFact:bb(1).BoundingBox(2)*resizeFact+bb(1).BoundingBox(4)*resizeFact,bb(1).BoundingBox(1)*resizeFact:bb(1).BoundingBox(1)*resizeFact+bb(1).BoundingBox(3)*resizeFact,:);
        ifin = ifin(bb(1).BoundingBox(2)*resizeFact:bb(1).BoundingBox(2)*resizeFact+bb(1).BoundingBox(4)*resizeFact,bb(1).BoundingBox(1)*resizeFact:bb(1).BoundingBox(1)*resizeFact+bb(1).BoundingBox(3)*resizeFact,:);
        eyeiorig = iorig (:,1:end/8,:);
        
        
        %detect upper fin
        [y,x] = find(ifin>0);
        finx = round(mean(x));
        finy = round(mean(y));
        
        %detect fish height
        ybott = size(mask,1);
        for ybott = size(mask,1):-1:1
            if (mask(ybott,round(finx/resizeFact))>0)
                break;
            end
        end
        
        %detect fish eye
        eye = rgb2gray(eyeiorig)<40;
        BWfish = bwlabel(eye);
        objectinfo = regionprops(BWfish,'Area','Centroid','BoundingBox');
        MaxSize = 0;
        id =0;
        for inew = 1:size(objectinfo,1)
            if objectinfo(inew).Area>MaxSize      
                if (objectinfo(inew).BoundingBox(1) > 0 && objectinfo(inew).BoundingBox(2) > 0 && objectinfo(inew).BoundingBox(1)+objectinfo(inew).BoundingBox(3) < size(eye,2) && objectinfo(inew).BoundingBox(2)+objectinfo(inew).BoundingBox(4) < size(eye,1))
                    MaxSize = objectinfo(inew).Area;
                    id=inew;            
                end
            end
        end
        eye =BWfish==id;
        xeye = objectinfo(id).Centroid(1);
        yeye = objectinfo(id).Centroid(2);
        
        length = round((size(iorig,2)-xeye));
        xr = finx;
        ybott = ybott * resizeFact;
        height = ybott - finy;
        yt = round((finy + height/100));
        yb = round((finy + height/2));
        if (yt < 11) yt = 11; end
        if (yb >size(eye,1)-10) yb = size(eye,1)-10; end
        %mod sesion 2 fish 19
        %yt = yt -20;
        %yb = yb -20;
        
        roi=iorig(yt:yb,xeye:xr,:);
        xl= xeye;
        imshow(iorig)
        hold on
        %plot the red stars on image in area of interest
        plot(finx,finy,'b*');
        plot(xeye,yt,'r*');
        iorig(yt-10:yt+10,xl-10:xl+10,1)=255;
        iorig(yt-10:yt+10,xl-10:xl+10,2)=0;
        iorig(yt-10:yt+10,xl-10:xl+10,3)=0;
        plot(xeye,yb,'r*');
        iorig(yb-10:yb+10,xl-10:xl+10,1)=255;
        iorig(yb-10:yb+10,xl-10:xl+10,2)=0;
        iorig(yb-10:yb+10,xl-10:xl+10,3)=0;
        plot(xr,yb,'r*');
        iorig(yb-10:yb+10,xr-10:xr+10,1)=255;
        iorig(yb-10:yb+10,xr-10:xr+10,2)=0;
        iorig(yb-10:yb+10,xr-10:xr+10,3)=0;
        plot(xr,yt,'r*');
        iorig(yt-10:yt+10,xr-10:xr+10,1)=255;
        iorig(yt-10:yt+10,xr-10:xr+10,2)=0;
        iorig(yt-10:yt+10,xr-10:xr+10,3)=0;
        plot(xeye,yeye,'b*');
        hold off
        drawnow

        %save the images in folders
        imwrite(iorig,[path '\' directories(dirsN).name '\output'  directories(dirsN).name '\' files(filesN).name(1:end-4) '.png']);
        imwrite(roi,[path '\' directories(dirsN).name '\roi'  directories(dirsN).name '\' files(filesN).name(1:end-4) '.png']);
        
    end
end
