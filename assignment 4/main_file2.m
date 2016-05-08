% our first program will read a csv file and get the matrix and also return the corresponding 
% RGB values for the given XYZ values for each image
data = csvread('ciexyz31_1.csv');

%% now normalizing the data
keys = [];
values = [];
for i = 1:size(data,1)
    data(i,[2 3 4]) = normalize(data(i,[2 3 4]));
    keys = [keys;get_angle([(data(i,2)- inv(3)) (data(i,3)- inv(3))])];
    values = [values;i+359];
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
% image = imresize(image,0.9,'bicubic');
im = image;

%% now get the histogram
histogram = get_normalized_histogram(image,keys,values);
plot(histogram);
