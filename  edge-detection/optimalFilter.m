function out = optimalFilter(img,angles,scales,C,n0)
% OPTIMALFILTER creates & runs the optimal edge detection filters on the img.
% Usage: out = optimalFilter(img,angles,scales,C,n0) 
%
% Inputs:
%	img:    the 2d image to process (must be square)
%   angles, scales: the orientations and gaussian scales to use
%   C,n0:  the image frequency parameters; if not given they are estimated from the image
%
% Output:
%   out: an array of filter outputs; the element out[x,y,a,s] gives the output of
%        the optimal filter with orientation angle[a] and scale scales[s] at the point
%        [x,y].
%
%
% The algorithm says that we apply a whitening filter to yield GW = W*img
% The whitening filter is W = D*B, where D is derivative & B is a Butterworth smoother.
% The resultant GW is a Butterworth impulse response, since derivative yields
% an impulse for a step edge; i.e. GW = B
% With scale space, the edge is GW = GAUSS*B. Thus the final computation is
% out = (GAUSS*B)*W*img/norm(GAUSS*B) = D*(GAUSS*B)*(B*img)/norm(GAUSS*B).

% check inputs
if any(max(size(img))~=size(img)) error('Image must be square'); end

if nargin==3
   [C,n0] = estimatePower(img);
   fprintf('Estimated C=%10.4f  and noise=%10.4f\n',C,n0)
end

% Calculate the frequency grid for the image
n = size(img,1);
[xfreq,yfreq] = meshgrid( [0:n/2-1,-n/2:-1]*2*pi/n );

% Butterworth filtering Bimg = B*img
butter = 1./sqrt(C^2+n0^2.*(xfreq.^2+yfreq.^2));
Bimg   = real(ifft2( fft2(img).*butter )); 

% apply the compromise filter.
Bimg = conv2([2 5 2]/9,[2 5 2]/9,Bimg,'same');

% Do the scale filtering
ns = length(scales);
Bimg = repmat(Bimg,[1 1 max(1,ns)]);
for s=1:ns
   % work out the scale filter GAUSS*B/norm(GAUSS*B)
   if scales(s)==0
      GAUSSB = butter;
   else
      GAUSSB = exp(-0.5*( (xfreq*scales(s)).^2 + (yfreq*scales(s)).^2 ) ).*butter;
   end
   % normalize the filter. This is the part I have the least confidence in.
   % There may be much better normalizations than this one.
   g = real(ifft2(GAUSSB));
   g = sum(g,1);
   nm = norm(g);
   GAUSSB = GAUSSB/nm;
   % apply to the filtered image
   Bimg(:,:,s) = real(ifft2( fft2(Bimg(:,:,end)).*GAUSSB )); 
end


% Compute the derivatives D = d/dx and d/dy
% The result is a whitened image, since whitening is derivative*butterworth
ns = max(1,ns);
DX = [diff(Bimg,1,2),zeros(n,1,ns)];
DY = [zeros(1,n,ns);-diff(Bimg,1,1)];

% run the oriented filtering by combining DX and DY
out = zeros(n,n,length(angles),ns);
for a = 1:length(angles)
   for s=1:ns
      rad = angles(a)*pi/180;
      dd  = cos(rad)*DX(:,:,s)+sin(rad)*DY(:,:,s);
      out(:,:,a,s) =  dd;
   end
end

% Clip the result at zero, since filtering at angle theta is same as the negative
% filtering at theta+180.
out = max(out,0);

% If no scales, need to reshape out to reflect that fact. Keeps matlab happy.
if length(scales)==1, out = reshape(out,[size(out),1]); end
