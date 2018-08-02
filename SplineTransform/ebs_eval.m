function   x1 = ebs_eval(p,x,w,nu,opt,param)
%Compute the transformed point locations of x, given an elastic body spline
% (EBS) in w and control points p. 
% x1 = ebs_eval(p,x,w,nu);
% p: n-by-d, control point matrix
% x: m-by-d, second point data matrix
% w: the coefficients of the splines, may be returned by ebs_fit.m
% nu: parameter of Poisson's ratio [0.49]
% x1: the transformed point locations
% 
% x1 = ebs_eval(p,x,w,nu,opt);
% opt: force type: opt=1 for f=c*r(x); opt=2 for f=c/r(x); opt=3 for
%      Gaussian force, or using x1 = ebs_eval(p,x,w,nu,'Gauss',sigma);
%      opt=4 for volume splines; opt=5 for 3d thin plate splines

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

% Ref: 
% [1] Davis et al (1997), "A Physics-Based Coordinate Transformation for 
%     3-D Image Matching", IEEE TMI, 16(3): 317-328
% [2] Kohlrausch, Rohr & Stiehl (2005), "A New Class of Elastic Body 
%     Splines for Nonrigid Registration of Medical Images", Journal of
%     Mathematical Imaging and Vision 23: 253-280

%% inputs
if  nargin<4, nu=0.49; end  % volume preserving as default
if  nargin<5 || isempty(opt), opt=1; end  % force type
if  strcmpi(opt(1),'g'), opt=3; end
if  nargin<6, param=[]; end  
% polynomial part
pflag=true;
if  opt==3, 
    if  isempty(param), 
        error('Sigma must be specified when using Gaussian force.'); 
    end; 
    pflag=false;
end
% pflag = (opt==3||strcmpi(opt(1),'g'));  
[n,d] = size(p);
[m,d2] = size(x); 
if  d2~=d, 
    fprintf('x and y must have the same dimension. \n'); 
    x1=[]; return; 
end

%% construct the new kernel
K = ebs_kernel(p,x,nu,opt,param);

%% compute the diplacement
if  pflag
    % construct the coefficients
    alpha = w(1:d*n);
    A = reshape(w(3*n+1:3*n+d*d),d,d);
    b = w(3*n+d*d+1:end);
    % 
    x1 = reshape(K*alpha,d,m)' + x*A' + b(:,ones(1,m))' + x;
else
    x1 = reshape(K*w,d,m)' + x;
end

