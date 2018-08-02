function   x1 = rbfs_eval(x,x0,c,type,param)
%Compute transformed x1 given rbfs in x and coefficients c, i.e. x1=f(x0)
% x1 = rbfs_fit(x,x0,lambda,type,param,pflag);
% x: n-by-d data matrix, as control points
% x0 and x1: m-by-d data matrix
% c: coefficients of the splines, may be returned by rbfs_fit.m
% type: the same as set in rbfs_fit.m
% param: the same as set in rbfs_fit.m
% x1: the transformed point locations

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

[n,d] = size(x);
[m,d2] = size(x0);
if  d2~=d,
    fprintf('x and x0 must have the same dimension. \n');
    x1=[]; return;
end
if  nargin<4, type='tps'; end
if  nargin<5, param=[]; end

% compute the kernel
K = rbfs_kernel(x0,x,type,param);

% construct the coefficients
pflag = size(c,1)>n;
if  pflag,
    alpha = [c(n+1:n+d+1,:),[zeros(d,1);1]];  % polynomial part
    beta = [c(1:n,:),zeros(n,1)];  % rbf part
    x1 = [ones(m,1),x0]*alpha + K*beta;
    x1 = x1(:,1:d);
else
    x1 = K*c + x0;
end

