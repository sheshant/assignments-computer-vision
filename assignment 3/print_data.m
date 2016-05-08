function print_data(points1,points2,i,j,fileID,image1,image2)
%% points 1 is of size 8x2
   fprintf(fileID,'\n*****************For image set %d and %d***************************\n\n',i,j);
   
   %% first we will start with the fundamental matrix
   Fmatrix = FundamentalMatrix(points1,points2);
   %[Fmatrix,~,~] = estimateFundamentalMatrix(points1,points2,'Method','Norm8Point');
   fprintf(fileID,'Fundamental Matrix\n');
   mat_to_file(Fmatrix,fileID);
   
   %% nest we need to show the epipoles
   fprintf(fileID,'epipoles\n ');
   [e1,e2] = epipoles(Fmatrix);
   fprintf(fileID,'e1 = (%f, %f) and e2 = (%f, %f)\n ',e1(1)/e1(3) ,e1(2)/e1(3) ,e2(1)/e2(3), e2(2)/e2(3));
   
   %% Now the lines passing through epipoles ie epipolar lines
   [line1,line2] = epipolar_lines(points1,points2,Fmatrix);
   fprintf(fileID,'epipolar lines for all points\n\n');
   for i = 1:size(line1,1)
       l1 = line1(i,:);
       l2 = line2(i,:);
       display(l1(1)*points1(i:1)+l1(2)*points1(i:2)+l1(3));
       display(l2(1)*points2(i:1)+l2(2)*points2(i:2)+l2(3));
       fprintf(fileID,' %d) l1 = (%f, %f, %f) and l2 = (%f, %f, %f)\n',i ,l1(1)/l1(3) ,l1(2)/l1(3) ,1 ,l2(1)/l2(3), l2(2)/l2(3), 1);
   end
   
   %% now we need to display lines
%    image1 = draw_line(image1,line1);
%    image2 = draw_line(image2,line2);
%    subplot(1,2,1), imshow(image1);
%    subplot(1,2,2), imshow(image2);
    subplot(1,2,1),
    image(image1),axis image,title('Left View');
    hold on
    for i = 1:size(line1,1)
        l1 = line1(i,:);
        [x,y] = draw_line(image1,l1);
        plot(x,y);
        hold on
    end
    
    subplot(1,2,2),
    image(image2),axis image,title('Right View');
    hold on
    for i = 1:size(line2,1)
        l2 = line2(i,:);
        [x,y] = draw_line(image2,l2);
        plot(x,y);
        hold on
    end 
   
   %% we need to show the camera matrix now 
   [camera1,camera2] = get_Camera(Fmatrix);
   fprintf(fileID,'\ncamera matrix for both the cameras\n\n');
   fprintf(fileID,'camera1\n');
   mat_to_file(camera1,fileID);
   fprintf(fileID,'camera2\n');
   mat_to_file(camera2,fileID);
   
   %% now we need to get the 3D points for all the pair of points
   fprintf(fileID,'\nCorresponding 3D points for all the points used for computation\n\n');
   for i = 1:size(points1,1)
       x1 = points1(i,:)' ;
       x2 = points2(i,:)' ;
       X = get_3Dpoint(x1,x2,camera1,camera2);
       fprintf(fileID,'\n %d) (%f, %f, %f)',i ,X(1) ,X(2) ,X(3));
   end
   fprintf(fileID,'\nDONE\n\n');
   
   %% we need to draw lines and save it also 
   
   %%   finished nothing left
end