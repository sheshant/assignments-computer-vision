a = imread('Twitter.png');
s = 1;
m = s*cos(pi/10);
n = s*sin(pi/10);
A = [m/n -n 0;
    n*m m+n 0;
    0 0 1];
tform = affine2d(A);
B = imwarp(a,tform);
imshow(B);