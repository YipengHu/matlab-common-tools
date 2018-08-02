function [v,cart,voxsize,roi,header] = read3DD(filename,header,voxsize,flag2d)
% for reading data from SonixMDP system, Ultrasonix
% Yipeng Hu (yipeng.hu@ucl.ac.uk)
% UCL Centre for Medical Image Computing, 2013-06


%% check the filename
if  exist(filename,'dir')==7,
    filename = fullfile(filename,'volume.3dd');
end
if  strcmpi(filename(end-3:end),'.xml');
    filename = filename(1:end-4);
end
if  ~strcmpi(filename(end-3:end),'.3dd');
    filename = [filename,'.3dd'];
end

% read in the header
if  nargin<2 || isempty(header),
    header = igitkUltrasonix.read3DDXML([filename,'.xml']);
end
% other options
if  nargin<3,
    voxsize = [];
end
if  nargin<4 || isempty(flag2d),
    flag2d = false;
end



%% read data
frameSize = header.lineNum * header.sampleNum;
nDataSize = frameSize * header.nimages_per_volume;

fid = fopen(filename);
% data = fread(fid,[frameSize,header.nimages_per_volume],'uint8=>uint8');
data = fread(fid,nDataSize,'uint8=>uint8');
fclose(fid);
% for  i = 1:header.nimages_per_volume,
%      data = fread(fid,[frameSize,header.nimages_per_volume],'uint8=>uint8');
% end
% data_vec = fread(fid,nDataSize,'uint8=>uint8');

data = reshape(data,header.sampleNum,[],header.nimages_per_volume);
% do any flip and cropping
data = data(:,(end:-1:1),:);  % just flipping
% data = data(header.roi.top+1:header.roi.bottom,(end:-1:1),:);
% data = data(header.roi.top+1:end,(end:-1:1),:);

% data = zeros(header.sampleNum,header.lineNum,header.nimages_per_volume,'uint8');
% data(:,header.roi.left:header.roi.right-1,:) = reshape(data_vec,header.sampleNum,[],header.nimages_per_volume);




%% parameters
% vox size
if  length(voxsize)==1,
    voxsize = voxsize.*ones(1,3-flag2d);
elseif  isempty(voxsize),  % using the same as MPP
    voxsize = [header.microns_pp.cx,header.microns_pp.cy]./1e3;  % mm/pix
end
% using bounding boxas default - see previous version for other defaults
volsize = [];

% using unit style as relative 3D spatial position is not important
lineRes = header.sampleDistance_mm / header.roiSampleNum;  % mm/linesample
% lineRes = header.sampleDistance_mm / header.sampleNum;  % mm/linesample
% lineRes = header.sampleDistance_mm / (header.roiSampleNum+header.roi.top);  % mm/linesample

depthOffset = header.frame_offset_mm;
switch   header.axis_offset_mm,
    case  6.8500,
        phiOffset = 12.58; % for header.axis_offset_mm=6.8500; roi.top=0; % - magic number to find out
    case  27.4880,
        phiOffset = 42.34;
    otherwise
        phiOffset = 12.58;  % to fix
        fprintf('Uncalibrated offfset distance!!!\n');
end

lineRadius = header.frame_angle/(header.lineNum-1) .*pi./180; % radius between lines
% lineRadius = header.frame_angle/(header.roi.right-header.roi.left) .*pi./180; % radius between lines

% output roi position - [buttom,left,right,top,origin]
roi = [ (header.roi.bottom-0.5)*lineRes, ...
    (header.roi.left+0.5)*lineRadius, ...
    (header.roi.right-0.5)*lineRadius, ...
    (header.roi.top+0.5)*lineRes ];

% if 3D, add slice radius
if  ~flag2d,
    sliceRadius = header.volume_angle/(header.nimages_per_volume-1) .*pi./180;  % radius between slices/frames
    if  length(voxsize)==2,
        voxsize(3) = voxsize(1);
    end
end


%% calling the scan conversion function
% tic;
if  ~flag2d,
    %% for 3D
    [v,cart.x,cart.y,cart.z,cart.oy2] = igitkUltrasonix.convertScan3D( data, ...
        lineRes,depthOffset,phiOffset, lineRadius,sliceRadius, voxsize,volsize);
    
else
    %% for 2D
    for  i = 1:header.nimages_per_volume,
        if  i==1,
            [v1,cart.x,cart.y] = igitkUltrasonix.convertScan2D( data(:,:,i), ...
                lineRes,depthOffset, lineRadius, voxsize,volsize);
            [volsize(2),volsize(1)] = size(v1);
            v = zeros(volsize(2),volsize(1),header.nimages_per_volume,'single');
            v(:,:,i) = v1;
        else
            v(:,:,i) = igitkUltrasonix.convertScan2D( data(:,:,i), ...
                lineRes,depthOffset, lineRadius, voxsize,volsize);
        end
    end
    
end  % flag2d
% toc;


%% shift the angle in 2d plane here - rotattion in xy plane
% work for both 2d and 3d
if  header.roi.left,
    radiusOffset = header.roi.left*lineRadius;
    cr=cos(radiusOffset); sr=sin(radiusOffset);
    xyi = [cart.x(:),cart.y(:)] * [cr,-sr;sr,cr]';
    cart.x(:) = xyi(:,1);  cart.y(:) = xyi(:,2);
end

