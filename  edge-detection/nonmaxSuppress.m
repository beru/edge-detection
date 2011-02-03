function mx = nonmaxSuppress(out,angles)
% mx = nonmaxSuppress(out,angles)
% does non-maximum suppression on out, which
% has coordinates [x,y,angle,scale]


% find oriented local max over scale, within orientation
mx = out;
for a=1:size(out,3)
   mx(:,:,a,:) = orientedpeak(out(:,:,a,:),angles(a));
end

% find local max over orientations
lmax = zeros(size(out));
for s=1:size(out,4)
   temp = out(:,:,:,s);
   temp = max(temp,out(:,:,[2:end,1],s));
   temp = max(temp,out(:,:,[end,1:end-1],s));
   lmax(:,:,:,s)=temp;
end
mx = mx & (out>=lmax) & (out>0);

% ===============================================================================

function ismax = orientedpeak(edges,angle)
% edges is an array [x,y,1,s], where x,y, and s range over
% the given dimensions (s is scale). The 3rd dimension is orientation
% which is fixed.

% First, we work out the interpolation to estimate the pixels fore and aft
% of each pixel, at the given orientation.
s2 = sqrt(0.5);
corners = [-s2 s2
   -1 0
   -s2 -s2
   0 1
   0 0
   0 -1
   s2 s2
   1 0 
   s2 -s2];

vec     = [cos(angle*pi/180),sin(angle*pi/180)];

wt = reshape(corners*vec',[3 3]);

fore = max(wt,0);
fore = fore/sum(fore(:));
aft  = max(-wt,0);
aft  = aft/sum(aft(:));

nhd_max = max(convn(edges,fore,'same'),convn(edges,aft,'same'));

ismax   = edges;
layerwt = sqrt(0.5); % this weights the neigbourhood maxima in scales different from the
                     % one being examined in the following code.
if size(edges,4)==1
   ismax(:,:,1)=edges>nhd_max(:,:,1);
else
   % do finest scale
   slice = edges(:,:,1,1);
   ismax(:,:,1,1) = ( slice>max( nhd_max(:,:,1,1),layerwt*nhd_max(:,:,1,2) ) ) & ...
      ( slice>edges(:,:,1,2) );
   % do intermediate scales
   for s=2:size(edges,4)-1
      slice = edges(:,:,1,s);
      ismax(:,:,1,s) = ( slice>max( nhd_max(:,:,1,s),...
         layerwt*max(nhd_max(:,:,1,s-1),nhd_max(:,:,1,s+1))) ) ...
         & ( slice>max( edges(:,:,1,[s-1,s+1]),[],4 ) );
   end
   % do coarsest scale
   slice = edges(:,:,1,end);
   ismax(:,:,1,end) = ( slice>max( layerwt*nhd_max(:,:,1,end-1),nhd_max(:,:,1,end) ) ) & ...
      ( slice>edges(:,:,1,end-1) );
end