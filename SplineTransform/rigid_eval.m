function  tx = rigid_eval(x,A,t)
%Apply the transformation on point data x, 
% tx = rigid_eval(x,A,t);
% tx = rigid_eval(x,T);
% tx=Ax+t, return transformed point locations, T=[A;t]; as in rigid_fit.m

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

[n,d] = size(x);
if  size(A,1)>d, t=A(d+1,:); A=A(1:d,1:d); end
tx = x*A + t(ones(n,1),:);