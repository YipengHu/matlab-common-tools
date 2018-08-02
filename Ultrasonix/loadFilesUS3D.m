function   [vol,par_rec,slice_size] = loadFilesUS3D(filenames,dirname,slice_size,mp_ext,erase_mode)

% sort out the directory name
if  ~any(strcmp(dirname(end),{'\','/'})), dirname=[dirname,'\']; end
if  ~strcmp(mp_ext(1),'.'), mp_ext=['.',mp_ext]; end

% only sort the extensions
num_slice = length(filenames);

% start reading straight away
% pre-allocate
if  ~isempty(slice_size),
    vol = zeros([slice_size,num_slice],'single');  % working faster in single
end
% recon_mat = cell(num_slice,1);
par_rec = zeros(2,num_slice);
for  i = 1:num_slice,
    
    nii = load_untouch_nii([dirname,filenames{i}]);
    vol(:,:,i) = nii.img';
    
    % try to read in motor positions now
    fid = fopen([dirname,strtok(filenames{i},'.'),mp_ext]);
    % recon_mat{i} = fscanf(fid,'%f %f %f %*f %f %f %f %*f %f %f %f %*f',[3,3])';
    % recon_mat{i} = fscanf(fid,'%f',[4,3])';  % pos = textscan(fid,'%f');
    % recon_mat = fscanf(fid,'%f %f %f %*f %f %f %f %*f %f %f %f %*f',[3,3]);   % to confirm - whether to transpose?
    par_rec(:,i) = fscanf(fid,'%f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f',2);
    fclose(fid);
    
    if  erase_mode, delete([dirname,filenames{i}]); end
    
end

if  isempty(slice_size),
    vol = single(vol);
    slice_size = [size(vol,1),size(vol,2)];
end