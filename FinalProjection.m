
clearvars

name = 'macro_image_';
number1 = '52650';%cut out trailing zeros
end1 = '63100';
ext = '.tiff';

dim1 = 3600/4;
dim2 = 1800/4;

filename = strcat(name,number1,ext);
filenameOut = strcat(name,'qproj_',number1,ext);
testFull=imread(filename);
image_original=testFull(:,:,1:3);

figure('Name','Mark 5 points on bubble edge');
    imshow(image_original);
    
    [x,y]=ginput(5);
    [R_pic,xc,yc]=circfit(x,y);
    
    clear x y
    image_marked = insertShape(image_original,'circle',[xc,yc,R_pic]);
    
    imshow(image_marked);
    
xc=round(xc);yc=round(yc);R_pic=round(R_pic);

R_max=R_pic;
    bg(1,1)=xc-R_max;   
%     bg(1,2)=xc_back-R_max;
    bg(2,1)=xc+R_max;   
%     bg(2,2)=xc_back+R_max;
    bg(3,1)=yc-R_max;   
%     bg(3,2)=yc_back-R_max;
    bg(4,1)=yc+R_max;   
%     bg(4,2)=yc_back+R_max;
i1=image_original(bg(3,1):bg(4,1),bg(1,1):bg(2,1),:);
% i2=imopen(back(bg(3,2):bg(4,2),bg(1,2):bg(2,2),:),strel('disk',5));

% image_cropped=uint8(double(i1)-double(i2*1));
image_cropped=i1;
% i3=i1(280:end-280,280:end-280,:);
% image_cropped=image_cropped(200:end-200,200:end-200,:);
image_cropped=image_cropped(1:end,1:end,1:3);

% imshow(test);
figure;imshow(i1);
clear R_back i1 i2 z test
%%
% crop image to save calculation time
close all;
pixel_data=double([]);
red_channel=image_cropped(:,:,1);
green_channel=image_cropped(:,:,2);
blue_channel=image_cropped(:,:,3);
pixel_data(:,1)=red_channel(:);
pixel_data(:,2)=green_channel(:);
pixel_data(:,3)=blue_channel(:);
[y_coors,x_coors]=ind2sub(size(red_channel),1:1:length(pixel_data(:,1)));
pixel_data(:,4)=x_coors';
pixel_data(:,5)=y_coors';

% calculate coordinates in flat image and create new projected image with inpolated pixeldata
image_center=double(ceil(size(image_cropped,1)/2));
pixel_data=double(pixel_data);
pixel_data((((pixel_data(:,4)-image_center).^2+(pixel_data(:,5)-image_center).^2).^0.5)>=R_pic,4:5)=NaN;
pixel_data(isnan(pixel_data(:,4))==1,:)=[];
pixel_data(:,6)=asin(((pixel_data(:,4)-image_center).^2+(pixel_data(:,5)-image_center).^2).^0.5/R_pic)*R_pic;
pixel_data(:,7)=atan2(pixel_data(:,5)-image_center,pixel_data(:,4)-image_center);
pixel_data(:,8)=round(sin(pixel_data(:,7)).*pixel_data(:,6));
pixel_data(:,9)=round(cos(pixel_data(:,7)).*pixel_data(:,6));
new_size=max(pixel_data(:,8));

pixel_data(:,8)=pixel_data(:,8)-min(pixel_data(:,8))+1;
pixel_data(:,9)=pixel_data(:,9)-min(pixel_data(:,9))+1;

[Y,X] = meshgrid(1:max(pixel_data(:,9)),1:max(pixel_data(:,8)));
red_new=uint8(griddata(pixel_data(:,8),pixel_data(:,9),pixel_data(:,1),X,Y));
green_new=griddata(pixel_data(:,8),pixel_data(:,9),pixel_data(:,2),X,Y);
blue_new=griddata(pixel_data(:,8),pixel_data(:,9),pixel_data(:,3),X,Y);

%
clear new_image
new_image(:,:,1)=([red_new(25:end-25,25:end-25)]);
new_image(:,:,2)=([green_new(25:end-25,25:end-25)]);
new_image(:,:,3)=([blue_new(25:end-25,25:end-25)]);
figure; imshow(new_image);