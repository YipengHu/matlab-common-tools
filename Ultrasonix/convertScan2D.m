function  [data_cartesian,xi,yi] = convertScan2D(data_scan, ...
    lineRes,depthOffset, lineRadius, img_res,img_size)
% for reading data from SonixMDP system, Ultrasonix
% Yipeng Hu (yipeng.hu@ucl.ac.uk)
% UCL Centre for Medical Image Computing, 2013-06


%% image voxel size
img_res_x = img_res(1);
img_res_y = img_res(2);

%% Polar coordinates of the scan line data in mm
[sampleNum,lineNum] = size(data_scan);
t = (-lineNum/2+.05:lineNum/2-0.5)*lineRadius+pi/2;
r = (0.5:sampleNum-0.5).*lineRes+depthOffset;
[t,r] = meshgrid(t,r);
% bounding box
if  nargin<6 || isempty(img_size),
    img_size_x = floor( abs(cos(t(1))*r(end))*2./img_res_x );
    img_size_y = floor( r(end)./img_res_y );
else
    img_size_x = img_size(1);
    img_size_y = img_size(2);
end

%% Polar coordinates of the b image in mm
% first the Cartesian coordinates
oi = [img_size_x/2*img_res_x,0];
xi = (0.5:img_size_x-0.5).*img_res_x - oi(1);
yi = (0.5:img_size_y-0.5).*img_res_y - oi(2);
[xi,yi] = meshgrid(xi,yi);
% then convert to the Polar: [ti,ri] = cart2pol(yi,xi);
ti = atan2(yi,xi);
ri = hypot(xi,yi);

%% interpolation
data_cartesian = interp2(t,r,single(data_scan),ti,ri,'*linear',0);
% figure, imshow(data_cartesian,[])


