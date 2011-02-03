function strong = hysteresis(localmax,contrast,angles,thresholds,plot)
% HYSTERESIS applies the hysteresis algorithm to improve edges

% Find the strong and weak edges.
strong = localmax & (contrast>thresholds(1));
weak   = localmax & (contrast>thresholds(2));

nstrong = sum(strong(:));
n = 0;
iter=0;
while nstrong~=n
   tic;
   n   = nstrong;
   disp(n)
   % find 3-by-3 nhd of each strong edgel in space
   nhd = convn(strong,ones(3,1,1,1),'same');
   nhd = convn(nhd,ones(1,3,1,1),'same');
   % find nhd of each edgel in orientation 
   nhd = convn(nhd,ones(1,1,3,1),'same');
   if ndims(strong)>3
      % find nhd of each edgel in scale - this nhd extends through
      % scale space
      nhd = convn(nhd,ones(1,1,1,3),'same');
   end
   nhd = nhd>0;
   sum(nhd(:))
   % if any weak edgels in nhd, make them strong
   strong  = strong | (nhd.*weak)>0;
   iter = iter+1;
   if plot
      showimg(makergb(sum(sum(strong,3),4)>0)),figure(gcf)
      title(sprintf('Growing edges step %4d',iter))
      drawnow
   end
   nstrong = sum(strong(:));
   toc
end
