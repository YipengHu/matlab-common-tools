function  [data_cartesian,xi,yi,zi,oy2] = convertScan3D(data_scan, ...
    lineRes,depthOffset,phiOffset, lineRadius,sliceRadius, img_res,img_size)
% for reading data from SonixMDP system, Ultrasonix
% Yipeng Hu (yipeng.hu@ucl.ac.uk)
% UCL Centre for Medical Image Computing, 2013-06


%% image voxel size
img_res_x = img_res(1);
img_res_y = img_res(2);
img_res_z = img_res(3);
% frame_radius = frame_angle.*pi./180;
% volume_radius = volume_angle.*pi./180;

%% Scan3D coordinates of the data in mm
[sampleNum,lineNum,nimages_per_volume] = size(data_scan);
th = (-lineNum/2+.05:lineNum/2-0.5)*lineRadius+pi/2;
r  = (0.5:sampleNum-0.5).*lineRes+depthOffset;
ph = (-nimages_per_volume/2+0.5:nimages_per_volume/2-0.5)*sliceRadius;
[th,r,ph] = meshgrid(single(th),single(r),single(ph));
oi(2) = -r(1)*sin(th(1));
oy2 = depthOffset-phiOffset;  % second y
% bounding box
if  nargin<8 || isempty(img_size),
    img_size_x = floor( abs(cos(th(1))*r(end))*2./img_res_x );
    img_size_y = floor( (r(end)+oi(2))./img_res_y );
    img_size_z = floor( abs(sin(ph(1))*(r(end)-oy2))*2./img_res_z );
else
    img_size_x = img_size(1);
    img_size_y = img_size(2);
    img_size_z = img_size(3);
end

%% pre-allocate
% data_cartesian = zeros([img_size_y,img_size_x,img_size_z],'single');

%% Scan3D coordinates of the b image in mm
% first the Cartesian coordinates
oi([1,3]) = [img_size_x/2*img_res_x,img_size_z/2*img_res_z];
xi = (0.5:img_size_x-0.5).*img_res_x - oi(1);
yi = (0.5:img_size_y-0.5).*img_res_y - oi(2);
zi = (0.5:img_size_z-0.5).*img_res_z - oi(3);
[xi,yi,zi] = meshgrid(xi,yi,zi);
% then convert to the Scan3D coordinates
hypotyz = hypot(yi,zi);
ri = hypot(xi,hypotyz);
thi = atan2(hypotyz,xi); % atan2(yi,xi);
phi = atan2(zi,yi-oy2);  % elevation phi = asin(zi./ri);  % elevation

%% interpolation
data_cartesian = interp3(th,r,ph,single(data_scan),thi,ri,phi,'*linear',0);
% figure, imshow(data_cartesian,[])


