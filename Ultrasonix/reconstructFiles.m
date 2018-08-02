function   [vol,vol_rec,par_rec,cxi,cyi,czi] = reconstructFiles(filenames,dirname,slice_size,mp_ext,erase_mode,vdims_out)

% motor position file extension
if  nargin<2 || isempty(dirname), dirname = '';    end
if  nargin<3 || isempty(slice_size), slice_size = [];    end
if  nargin<4 || isempty(mp_ext), mp_ext = '.motor_position.txt'; end
if  nargin<5 || isempty(erase_mode), erase_mode = false; end
if  nargin<6 || isempty(vdims_out), vdims_out = [1,1,1]; end

%% read in files  % test only -  mp_ext = 'motor_position';
[vol,par_rec,slice_size] = igitkUltrasonix.loadFilesUS3D(filenames,dirname,slice_size,mp_ext,erase_mode);


%% now reconstruction
if  nargout>1,
    % get coordinates
    if  nargout<4,
        [cxi,~,~,it0,px0,pr0,pt0,pti,pri] = igitkUltrasonix.getCoordinates(slice_size,par_rec,vdims_out);
    else
        [cxi,cyi,czi,it0,px0,pr0,pt0,pti,pri] = igitkUltrasonix.getCoordinates(slice_size,par_rec,vdims_out);
    end
    % sort the volume
    vol = vol(:,:,it0);
    % interpolation
    vol_rec = interpn(pr0,px0,pt0,vol,pri,cxi,pti,'*linear',0); 
end

