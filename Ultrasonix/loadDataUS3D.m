function   [vol,par_rec,track_Rs,track_ts] = loadDataUS3D(dirname, slice_size, erase_mode)


if  nargin<2 || isempty(slice_size), slice_size = [];    end
if  nargin<3 || isempty(erase_mode), erase_mode = false; end


% sort out the directory name
if  ~any(strcmp(dirname(end),{'\','/'})), dirname=[dirname,'\']; end

% read in motor position
list_filenames = dir([dirname,'*.motor_position']);  
if  isempty(list_filenames), 
    fprintf('No motor_position file found!!!\n');    
    vol=[]; par_rec=[]; track_Rs=[]; track_ts=[]; 
    return;
end
num_slice = length(list_filenames);

% pre-allocate
if  ~isempty(slice_size),
    vol = zeros([slice_size,num_slice],'single');  % working faster in single
end
% recon_mat = cell(num_slice,1);
par_rec = zeros(2,num_slice);
track_Rs = zeros(3,3,num_slice);
track_ts = zeros(3,num_slice);


for  i = 1:num_slice,
    
    filename = list_filenames(i).name;
    
    %% read in image, ...
    nii = load_untouch_nii([dirname,strtok(filename,'.'),'.ultrasoundImage.nii']);
    vol(:,:,i) = nii.img';
    
    % tracking matrix ... - use only the first
    track_Rs(:,:,i) = [nii.hdr.hist.srow_x(1:3); nii.hdr.hist.srow_y(1:3); nii.hdr.hist.srow_z(1:3)];
    track_ts(:,i) = [nii.hdr.hist.srow_x(4); nii.hdr.hist.srow_y(4); nii.hdr.hist.srow_z(4)];    
    % nii.hdr.hist.quatern_b
    
    % and slice position
    fid = fopen([dirname,filename]);  
    % recon_mat{i} = fscanf(fid,'%f %f %f %*f %f %f %f %*f %f %f %f %*f',[3,3])';  
    % recon_mat{i} = fscanf(fid,'%f',[4,3])';  % pos = textscan(fid,'%f');
    % recon_mat = fscanf(fid,'%f %f %f %*f %f %f %f %*f %f %f %f %*f',[3,3]);   % to confirm - whether to transpose?
    par_rec(:,i) = fscanf(fid,'%f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f',2);   
    fclose(fid);
    
    if  erase_mode, delete([dirname,filename]); end
        
end

if  isempty(slice_size),
    % slice_size = [size(vol,1),size(vol,2)];
    vol = single(vol);
end
