function im2 = colourcode(im,map)
% This flattens the 3 dim image by colour coding the last dimension.

im = im-min(im(:));
im = im/max(im(:));

map = feval(map,size(im,3));

im2 = 0;
for i=1:size(im,3)
   slice = im(:,:,i);
   im2 = im2+cat(3,slice*map(i,1),slice*map(i,2),slice*map(i,3));
end
im2 = uint8(round(im2*255));