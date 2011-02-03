function strong = hysteresis(localmax,contrast,angles,thresholds,plot)
% HYSTERESIS applies the hysteresis algorithm to improve edges

% Find the strong and weak edges.
strong = localmax & (contrast>thresholds(1));
weak   = localmax & (contrast>thresholds(2));

nstrong = sum(strong(:));
n = 0;
iter=0;
while nstrong~=n
   n   = nstrong;
   nhd = strong;
   nhd(2:end-1,:,:,:) = nhd(2:end-1,:,:,:)+nhd(1:end-2,:,:,:)+nhd(3:end,:,:,:);
   nhd(:,2:end-1,:,:) = nhd(:,2:end-1,:,:)+nhd(:,1:end-2,:,:)+nhd(:,3:end,:,:);
   nhd(:,:,2:end-1,:) = nhd(:,:,2:end-1,:)+nhd(:,:,1:end-2,:)+nhd(:,:,3:end,:);
   if ndims(strong)>300
      % find nhd of each edgel in scale - this nhd extends through
      % scale space
      nhd(:,:,:,2:end-1) = nhd(:,:,:,2:end-1)+nhd(:,:,:,1:end-2)+nhd(:,:,:,3:end);
   end
   nhd = nhd>0;
   % if any weak edgels in nhd, make them strong
   strong  = strong | (nhd.*weak)>0;
   iter = iter+1;
   if plot
      showimg(makergb(sum(sum(strong,3),4)>0)),figure(gcf)
      title(sprintf('Growing edges step %4d',iter))
      drawnow
   end
   nstrong = sum(strong(:));
end
