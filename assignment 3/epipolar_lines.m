function [line1,line2] = epipolar_lines(points1,points2,Fmatrix)
    line1 = [];
    line2 = [];
    F1 = Fmatrix;
    F2 = Fmatrix';
    % here line 1 is l and line 2 is l'
    % both the lines will become NX3 matrices for the given n points
    %% first thing get all the point ie padding with 1
    if(size(points1,2) ~= 3)
        points1 = padarray(points1,[0 1],1,'post');
        points2 = padarray(points2,[0 1],1,'post');
    end
    %% now next part get lines
    % l' = F1x is the epipolar line corresponding to x.
    % l = F2x' is the epipolar line corresponding to x'.
    for i = 1:size(points1,1)
        % for line 1
        x2 = points2(i,:)';
        line1 = [line1;(F2*x2)'];
        % for line 2
        x1 = points1(i,:)';
        line2 = [line2;(F1*x1)'];
    end
end