function showimg(img,scale)
% SHOWIMG shows an image, with proper onscreen pixel scaling
% Usage: showimg(img,scale)
% Inputs:
%	img :  a matrix of pixel intensity values
%  scale: how many onscreen pixels to represent a single image pixel (default=1)

% Just show the image unscaled first
image(img), colormap gray, axis image

% work out the scale
sz = size(img); sz=sz(1:2);
if nargin==1, scale=1; end
sz=fliplr(sz)*scale;

% Now scale the figure axes to get the right number of pixels.
set(gca,'units','pixels')
ap = get(gca,'pos');
set(gca,'pos',[round(ap(1:2)),sz]);
p = get(gcf,'pos');
p(3:4) = sz+[50,30]+round(ap(1:2));
righttop = p(1:2)+p(3:4);
ssz = get(0,'screensize');
p(1:2) = p(1:2) - max(0,righttop-ssz(3:4)+[20 100]);
set(gcf,'pos',p)