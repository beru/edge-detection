function img = makergb(img)
% MAKERGB turns a greyscale image into an rgb image 

m = min(img(:));
img = img-m;
m = max(img(:));
img = uint8(round(255*img/m));
img = cat(3,img,img,img);
