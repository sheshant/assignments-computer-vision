image{1} = imread('DSC_0244.jpg');
image{2} = imread('DSC_0245.jpg');
image{3} = imread('DSC_0246.jpg');
image{4} = imread('DSC_0247.jpg');

fileID = fopen('results.txt','w');

%% main computation begins here 
i = input('Enter first image index');
j = input('Enter second image index');
[points1,points2] = show_images(image{i},image{j}); 

%% now we need to call the print data file 
if(size(points1,1) == 8 && size(points2,1) == 8)
    print_data(points1,points2,i,j,fileID,image{i},image{j});
else
    fprintf('error\n');
end
%% main computation ends

fclose(fileID);

