function   [cxi,cyi,czi,it0,px0,pr0,pt0,pti,pri] = getCoordinates(slice_size,par_rec,vdims_out)

% return the Cartesian image coordinates for reconstructed image

% polar coordinates: px, pr, pt
% in-use conversion to cart. coordinates: 
% cx = px; 
% cy = pr * sin(pt);
% cz = pr * cos(pt);



%% original polar coordinates
if  any(diff(par_rec(1,:))>sqrt(eps)), % single precision
    fprintf('WARNING:The scalings may not be consistent over slices - use the first one\n.'); 
end
px0 = (1:slice_size(2)).*par_rec(1);
pr0 = (1:slice_size(1)).*par_rec(1);
if  nargout<4,
    pt0 = acos(par_rec(2,:));  % this needs to be sorted when actual values are available
else
    [pt0,it0] = sort(acos(par_rec(2,:)),'ascend');
    % vol = vol(:,:,it0);  for the tracking as well !!!
end
% only useful to compute the range
cz0 = pr0' * sin(pt0);  
cy0 = pr0' * cos(pt0);  

%% polar coordinates in reconstructed space - 0.5 used to sufficiently capture the intensities
cxi = (min(px0)-0.5:vdims_out(2):max(px0)+0.5);
cyi = (min(cy0(:))-0.5:vdims_out(1):max(cy0(:))+0.5);
czi = (min(cz0(:))-0.5:vdims_out(3):max(cz0(:))+0.5);

if  nargout<8, return; end  
% [cxi,cyi,czi] = meshgrid(cxi,cyi,czi);
[cyi,cxi,czi] = ndgrid(cyi,cxi,czi);
pti = atan2(cyi,czi);
pri = hypot(czi,cyi);



