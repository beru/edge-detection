% Driver script for 2D edge detection. 

% Load the image & convert to greyscale
img = imread('metal.jpg');
img = mean(double(img),3)/255;
img = min(1,max(0,img));
showimg(makergb(img)), title('Input image')

% Add some noise
noise = input('Noise level: '); % Used 0.2 in figure 8 of the paper, otherwise 0.
img = img + noise*randn(size(img));
img = min(1,max(0,img));
if noise>0
   showimg(makergb(img)), title('Noisy image; hit space to continue'); pause
end

% Set parameters
params = struct('filterscales',[0 1 2 3],...     % the gaussian filter scales; use 0 to get a straight DISEF filter
   'threshold',[0.75,0.05],...      % the hysteresis thresholds, use [1 0.5] when noise present
   'angles',0:15:359);              % the orientations to process

% do the optimal filtering.
filtered = optimalFilter(img,params.angles,params.filterscales);
fprintf('optimal edge filters done\n');

% find the local maxima in the output image.
localmax = nonmaxSuppress(filtered,params.angles);

% Now use a hysteresis algorithm to join these local maxima together into edges
edges = hysteresis(localmax,filtered,params.angles,params.threshold,1);

% remove spots
spots = convn(edges,ones(3,3,3),'same')<2;
edges = edges.*(1-spots);

% color code one of the dimensions and remove the other
if length(size(edges))==4
   flattened = colourcode(reshape(sum(edges,3)>0,[size(edges,1),size(edges,2),size(edges,4)]),'hsv');
else
   flattened = makergb(reshape(sum(edges,3)>0,[size(edges,1),size(edges,2)]));
end

% show result
showimg(cat(2,makergb(img),flattened))

