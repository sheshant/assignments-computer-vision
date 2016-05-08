% our first program will read a csv file and get the matrix and also return the corresponding 
% RGB values for the given XYZ values for each image
data = csvread('ciexyz31_1.csv');

%% now normalizing the data
for i = 1:size(data,1)
    data(i,[2 3 4]) = normalize(data(i,[2 3 4]));
    keys = [keys;get_angle([(data(i,2)- inv(3)) (data(i,3)- inv(3))])];
    values = [values;i+359];
end

%% now reading all the images 

directory = strcat(pwd,'\color\*.jpg');
srcFiles = dir(directory);  % the folder in which ur images exists
if(isempty(srcFiles))
    fprintf ('error unable to read images as directory is unavailable\n');
end
images = cell(length(srcFiles),1);
for i = 1 : length(srcFiles)
    filename = strcat('color\',srcFiles(i).name);
    I = imread(filename);
    I = imresize(I,0.5,'bicubic');
    images{i} = I;
end

% good we got the images 
%% now we will get the matrix and histograms one by one 
% matrix = cell(length(srcFiles),1);
histograms = cell(length(srcFiles),1);
for i = 1 : length(srcFiles)
%     matrix{i} = get_matrix(images{i},data);
%     [~,histograms{i}] = histogram_eq(images{i},matrix{i},data);
    histograms{i} = get_normalized_histogram(images{i},keys,values);
    histograms{i}(1:359) = [];
end

%% now next job is getting histogram of all the images 
k = [2;3;4];
labels = [];
for i = 1:3
    labels = [labels get_labels(k(i),histograms)];
end

%% good now the printing begins
fprintf('\nResults\n\n');
fprintf('K = 1\tK = 2\tK = 3\n\n');
for i = 1 : length(srcFiles)
    fprintf('%d\t\t%d\t\t%d\n',labels(i,1),labels(i,2),labels(i,3));
end

