function   [A,t] = rigid_fit(x,y,opt)
%Compute the rigid/affine transformation between two sets of points, x y,
% so that ||y-(Ax+t)|| is minimised
% [A,t] = rigid_fit(x,y,opt);
% T = rigid_fit(x,y,opt);
% p: n-by-d, control point matrix
% x: m-by-d, point data matrix
% opt: 'rigid', 'affine' or 'rigid7' (with isotropic scaling)
% T = [A;t]; if single output

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

if  nargin<3, opt='rigid'; end

[n,d] = size(x); [n2,d2] = size(y);
if  d2~=d || n~=n2, fprintf('ERROR: x and y must have the same size. \n'); 
    A=[];t=[]; return; 
end

% centering
mx = mean(x,1);
my = mean(y,1);
x = x-mx(ones(n,1),:);
y = y-my(ones(n,1),:);

% compute A
switch  lower(opt(1:5)),

    case  'rigid',
        sflag=strcmpi(opt,'rigid7');
        if  sflag,
            xnorm = sqrt(trace(x*x'));  % sqrt(sum(nX(:).^2));
            ynorm = sqrt(trace(y*y'));  % sqrt(sum(nY(:).^2));
            x = x/xnorm;  y = y/ynorm;
        else  s = 1;
        end
        % SVD calculates rotation R
        [U,S,V] = svd(y'*x);
        R = V*diag([ones(1,d-1),det(V*U')])*U';  % R = V*U';
        if  sflag, s=sum(diag(S))*ynorm/xnorm; end
        A = s*eye(d)*R;

    case  'affin',
        A = x \ y;

end

% translations
t = my - mx*A;

if  nargout==1, A = [A;t]; end
