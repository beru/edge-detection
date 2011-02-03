function strong = hysteresis(localmax,contrast,angles,thresholds,plot)

% Find the strong and weak edges.
strong = localmax & (contrast>thresholds(1));
weak   = localmax & (contrast>thresholds(2));

strongidx = findidx(strong);
% Repeatedly look at neighbours of strong points. If weak, promote to strong
for i=1:100
	tic;
   fprintf('i=%d\n',i)
   nstrong = size(strongidx,1);
   disp(nstrong)
   s   = nhd(strongidx,size(strong));
   idx = sub2ind(size(strong),s(:,1),s(:,2),s(:,3),s(:,4));
   idx = idx(weak(idx)==1);
   [s1,s2,s3,s4] = ind2sub(size(strong),idx);
   strongidx = [s1,s2,s3,s4];
   toc
   if size(strongidx,1)==nstrong, break, end
end

% now redo strong
idx = sub2ind(size(strong),strongidx(:,1),strongidx(:,2),strongidx(:,3),strongidx(:,4));
strong(idx)=1;

% ---------------------------------------------------------------------------

function idx = findidx(m)
% assumes 4 dimensions at most
[d1,d2,d3,d4] = ind2sub(size(m),find(m));
idx = [d1,d2,d3,d4];

function n = nhd(idx,sz)
% Creates the 4-dim neighbourhood of the indices
n = [];
for d1=[-1 0 1]
   n1  = idx(:,1)+d1;
   ok1 = n1>0 & n1<=sz(1);
   for d2=[-1 0 1]
      n2  = idx(:,2)+d2;
      ok2 = ok1 & n2>0 & n2<=sz(2);
      for d3=[-1 0 1]
         n3  = idx(:,3)+d3;
         ok3 = ok2 & n3>0 & n3<=sz(3);
         for d4=[-1 0 1]
            n4 = idx(:,4)+d4;
            ok = n4>0 & n4<=sz(4) & ok3;
            n = [n; n1(ok), n2(ok), n3(ok), n4(ok)];
         end
      end
   end
end
n = unique(n,'rows');