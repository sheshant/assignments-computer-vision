% our first program will read a csv file and get the matrix and also return the corresponding 
% RGB values for the given XYZ values for each image
data = csvread('ciexyz31_1.csv');

%% now normalizing the data
d = [];
for i = 1:size(data,1)
    data(i,[2 3 4]) = normalize(data(i,[2 3 4]));
%     fprintf('%d)\t%f \n',i+359,get_angle([(data(i,2)- inv(3)) (data(i,3)- inv(3))]));
%     d = [d;[i+359 get_angle([(data(i,2)- inv(3)) (data(i,3)- inv(3))])]];
%     plot(d(:,1),d(:,2));
end

%% now we will read an image and convert the matrix into a matrix of only wavelength 
% we w
[filename, pathname] = uigetfile({'*.png;*.jpg;*.bmp;*.tif','Supported images';...
                 '*.png','Portable Network Graphics (*.png)';...
                 '*.jpg','J-PEG (*.jpg)';...
                 '*.bmp','Bitmap (*.bmp)';...
                 '*.tif','Tagged Image File (*.tif,)';...
                 '*.*','All files (*.*)'});
image = strcat(pathname,filename);
img = imread(image);
image = img;
image = imresize(image,0.5,'bicubic');
im = image;
matrix = get_matrix(image);
%% 360 to 480 unknown, must be infrared
%% 480 to 505 blue
%% 505 to 565 green
%% 565 to 575 yellow
%% 575 to 595 orange
%% 595 to 660 red
%% 660 to 700 (ya both are lost somewhere)
start = input('Enter first wavelength\n');
finish = input('Enter second wavelength\n');
start_cuttoff = rem(get_angle([(data((finish - 359),2)- inv(3)) (data((finish - 359),3)- inv(3))])+10 , 360);
finish_cuttoff = rem(get_angle([(data((start - 359),2)- inv(3)) (data((start - 359),3)- inv(3))])+10 , 360);


%% here the filtering begins
row = size(image,1);
col = size(image,2);
for i = 1:row
	for j = 1:col
        
        %% compute the tan
        val = rem(matrix(i,j) + 10, 360);
        if(start_cuttoff > finish_cuttoff)
            if(~(val >= start_cuttoff || val <= finish_cuttoff))
                image(i,j,1) = 0;
                image(i,j,2) = 0;
                image(i,j,3) = 0;
            end
        else
             if(~(val >= start_cuttoff && val <= finish_cuttoff))
                image(i,j,1) = 0;
                image(i,j,2) = 0;
                image(i,j,3) = 0;
             end
        end
    end
end
subplot(1,2,1);
imshow(im);
subplot(1,2,2);
imshow(image);
