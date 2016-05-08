% we have to read all the images from the folder RGBD data
%% read all images 
images = {};
range_images = {};
store = {};
images{1} = imread('RGBD data/0.jpg');
range_images{1} = imread('RGBD data/0.png');
images{2} = imread('RGBD data/1.jpg');
range_images{2} = imread('RGBD data/1.png');
images{3} = imread('RGBD data/2.jpg');
range_images{3} = imread('RGBD data/2.png');
images{4} = imread('RGBD data/3.jpg');
range_images{4} = imread('RGBD data/3.png');
images{5} = imread('RGBD data/4.jpg');
range_images{5} = imread('RGBD data/4.png');


keySet = [1,2,3,4,5,6,7,8,9];
valueSet1 = {'peak','ridge','saddle','ridge','flat','valley','saddle','valley','pit'};
valueSet2 = {'peak','ridge','Saddle ridge','none','flat','Minimal surface','pit','valley','Saddle valley'};
map1 = containers.Map(keySet,valueSet1);
map2 = containers.Map(keySet,valueSet2);

%% done now compute everything from everything

for i = 1:5
    %% here the code begins 
    row = size(range_images{i},1);
    col = size(range_images{i},2);
    % we need to first compute all the gradients in all directions 
    % fx2 fy2 fxx fyy fxy
    [fx,fy] = imgradientxy(range_images{i});
    [fxx,fxy] = imgradientxy(fx);
    [~,fyy] = imgradientxy(fy);
    fx2 = fx.*fx;
    fy2 = fy.*fy;
    
    %% cool we got everything now we need to get the corresponding curvatures 
    % link http://users.vcnet.com/simonp/curvature.pdf
    one = ones(size(range_images{i}));
    
    %% gaussian curvature 
    %K = (fxx*fyy - fxy^2)/(1 + fx^2 + fy^2)^2
    K = ((fxx.*fyy) - fxy.^2)./((one + fx.^2 + fy.^2).^2);
    
    %% mean curvature
    H = ((one + fx.^2).*fyy + (one + fy.^2).*fxx - 2*((fx.*fy).*fxy))./(2*((one + fx.^2 + fy.^2).^(1.5)));
    
    %% principle curvature
    k1 = H + sqrt(H.^2 - K);
    k2 = H - sqrt(H.^2 - K);
    
    %% now perform second operation 
    % in second operation we need to get the local topology
    % a )   principle curvature 
    surface1 = comparison(k1,k2);
    % got it now we need to get all the numbers proper ie 
    % 1 peak => 1 
    % 2,4 ridge => 2
    % 3,7 saddle => 3
    % 5 flat => 4
    % 6,8 valley => 5 
    % 9 pit => 6
    surface1(surface1 == 4) = 2;
    surface1(surface1 == 7) = 3;
    surface1(surface1 == 5) = 4;
    surface1(surface1 == 6 | surface1 == 8) = 5; 
    surface1(surface1 == 9) = 6;
    
    % b )   mean and gaussian
    surface2 = comparison(K,H);
    % got it and the numbers are already proper 
    
    %% now perform last operation 
    % in this operation we need to find all the connected components 
    imwrite(get_image(surface1),strcat('image ',num2str(i),'1.bmp'));
    imwrite(get_image(surface2),strcat('image ',num2str(i),'2.bmp'));
    
    %% now display all of them in separate files 
%     fileID = fopen(strcat('data for image ',num2str(i-1),'.txt'),'w');
%     display_matrix(fileID,surface1,'surface topology from principle curvature');
%     display_matrix(fileID,surface1,'surface topology from mean and gaussian curvature');
%     fclose(fileID);
    
end

%% now the second part 