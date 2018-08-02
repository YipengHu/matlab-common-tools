function  vol_recon = PolarInterpolation(vol,par_rec,slice_size,vdims_out)


% polar coordinates: px, pr, pt
% in-use conversion to cart. coordinates: 
% cx = px; 
% cy = pr * sin(pt);
% cz = pr * cos(pt);


% original polar coordinates
% check the 
if  any(diff(par_rec(1,:))>sqrt(eps)), % single precision
    fprintf('WARNING:The scalings may not be consistent over slices - use the first one\n.'); 
end
px0 = (0.5:slice_size(2)-0.5).*par_rec(1);
pr0 = (0.5:slice_size(1)-0.5).*par_rec(1);
% temp sorting fix - this is the only thing would work with the algorithm
[pt0,it0] = sort(acos(par_rec(2,:)),'ascend');  % pt0 = acos(par_rec(2,:));
vol = vol(:,:,it0);
% for the tracking as well !!!

% polar coordinates in reconstructed space
cz0 = pr0' * sin(pt0);  % only useful to compute the range
cy0 = pr0' * cos(pt0);  % only useful to compute the range
cxi = (min(px0)-0.5:vdims_out(2):max(px0)+0.5);
cyi = (min(cy0(:))-0.5:vdims_out(1):max(cy0(:))+0.5);
czi = (min(cz0(:))-0.5:vdims_out(3):max(cz0(:))+0.5);
% [cxi,cyi,czi] = meshgrid(cxi,cyi,czi);
[cyi,cxi,czi] = ndgrid(cyi,cxi,czi);
pti = atan2(cyi,czi);
pri = hypot(czi,cyi);

% for test plot of the coordinates
% [grid0_x,grid0_r,grid0_t] = meshgrid(px0,pr0,pt0);
% figure,  plot3(grid0_x(:),grid0_r(:).*cos(grid0_t(:)),grid0_r(:).*sin(grid0_t(:)),'b.');
% hold on; plot3(cxi(:),pri(:).*cos(pti(:)),pri(:).*sin(pti(:)),'g.'); axis equal;
% % in polar space
% figure,  plot3(grid0_x(:),grid0_r(:),grid0_t(:),'b.');
% hold on; plot3(cxi(:),pri(:),pti(:),'g.');

% interplation
vol_recon = interpn(pr0,px0,pt0,vol,pri,cxi,pti,'*linear',0); 
% vol_recon = interp3(px0,pr0,pt0,vol,cxi,pri,pti,'*linear',0); 
% - this has an unknown problem for recent version of matlab
% vol_recon = interp3(grid0_r,grid0_t,grid0_x,vol,cxi,pri,pti,'*linear',0);
% for i=1:size(vol_recon,3), imshow(vol_recon(:,:,i),[]); pause; end






