function [points1,points2] = show_images(image1,image2)
    % we are using getpts here for
    %fig = Figure('Select corresponding points');
    img1hndl = subplot(1,2,1);
    image(image1),axis image,title('Left View');
    img2hndl = subplot(1,2,2);
    image(image2),axis image,title('Right View');

    [x1,y1] = getpts(img1hndl);
    pt1 = [x1 y1];

    [x2,y2] = getpts(img2hndl);
    pt2 = [x2 y2];
    
    %% now we need to swap x and y with each other for both points set 
    points1 = [pt1(:,2) pt1(:,1)];
    points2 = [pt2(:,2) pt2(:,1)];
    
end