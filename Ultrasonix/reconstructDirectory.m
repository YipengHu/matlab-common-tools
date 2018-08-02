function   [vol_recon,mat_track] = reconstructDirectory(dirname, slice_size, vdims_out, filename_out, type_out, erase_mode)


if  nargin<2 || isempty(slice_size), slice_size = [];      end
if  nargin<3 || isempty(vdims_out),  vdims_out = [1,1,1];  end
if  nargin<6 || isempty(erase_mode), erase_mode = false;   end

%% load data
[vol,par_rec,track_Rs,track_ts] = igitkUltrasonix.loadDataUS3D(dirname,slice_size,erase_mode);
if  isempty(vol), vol_recon=[]; mat_track=[]; return;  end
slice_size = [size(vol,1),size(vol,2)];


%% reconstruction
vol_recon = PolarInterpolation(vol,par_rec,slice_size,vdims_out);

%% averaging the tracking matrix
[R,t] = MeanTransformation(track_Rs,track_ts);
mat_track = [R,t];
%  mat_track = [track_Rs(:,:,1),track_ts(:,1)];  % use the first one

%% write into a file
if  nargin<4 || isempty(filename_out), return;  end
if  nargin<5 || isempty(type_out),  type_out=2; end

% only if write into nifti
nii = make_nii(permute(vol_recon,[2,1,3]),vdims_out,[],type_out);

% add the tracking matrix
nii.hdr.hist.sform_code=1;
nii.hdr.hist.srow_x = mat_track(1,1:4);
nii.hdr.hist.srow_y = mat_track(2,1:4);
nii.hdr.hist.srow_z = mat_track(3,1:4);
% nii.hdr.hist.qform_code=2;
% nii.hdr.hist.qoffset_x=mat_track(1,4);
% nii.hdr.hist.qoffset_y=mat_track(2,4);
% nii.hdr.hist.qoffset_z=mat_track(3,4);

save_nii(nii,filename_out);
% save_untouch_nii(nii,filename_out);

