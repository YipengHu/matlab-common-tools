% CD to folder with US scan, e.g. cd E:\THIFU\Ultrasonix_3DUS_CMIC\10-18-2013-Generic
% and run script

flag2d = false % if true, conversion is just a stack of 2D slices (no real world coordinate system)


d = dir;

hw = waitbar(0,'Please wait');
count = 0;
for i = 3:numel(d)
    waitbar(i/numel(d),hw)
    if isdir(d(i).name)
        count = count + 1;
        [path,name,ext] = fileparts(d(i).name);
        fprintf('processing %d. volume: %s...\n',count,name)
        
        if flag2d
            outvoxsize = [];
        else
            outvoxsize = [1 1 1]; % to avoid memory allocation errors
        end
        [v,cart,voxsize,roi,header] = igitkUltrasonix.read3DD(d(i).name,[],outvoxsize,flag2d);
        if flag2d
            voxsize = [voxsize 1];
            outsuffix = '_stack.nii.gz';
        else
            outsuffix = '_volume.nii.gz';
        end
        write_nifti_volume(int16(v),voxsize,[d(i).name,filesep,'3DUS_',name,outsuffix]);
    end
end
fprintf('Processed a total of %d. volumes!\n',count)
close(hw)
