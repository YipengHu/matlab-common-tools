%  examples_guidedcpd_120709

% compile the c code first:
%   mex cpd_P.c
%   mex cpd_P_guided.c
% alternatively, rename the m files:
%   cpd_P_m.m -> cpd_P.m
%   cpd_P_guided_m.m -> cpd_P_guided.m


%%%%%%%%%%%%%%%%%%%%%%%%%%
% example 02 - 2D vessel %
%%%%%%%%%%%%%%%%%%%%%%%%%%
% load vessel
clear all; close all
load('data_ex02_vess');

% normal nonrigid CPD
opt.method = 'nonrigid';  % 'affine';
opt.beta = 5;  % smoothness
opt.viz = true;
[Transform,Normal] = cpd_register_guided(X,Y,opt);
tY = cpd_transform_nn(Y,Transform,Normal);  % registered points
tLMY = cpd_transform_nn(LMY,Transform,Normal);  % warping landmarks too

% landmark-guided CPD
opt.method = 'nonrigid_guided';  % 'affine_guided';
opt.gX = LMX;  opt.gY = LMY;  % load in landmarks (apex/base)
opt.ss2 = 1e-5;  % hyper parameter for landmarks
opt.beta = 5;  % smoothness
opt.viz = true;
[Transform_g,Normal_g] = cpd_register_guided(X,Y,opt);
tY_g = cpd_transform_nn(Y,Transform_g,Normal_g);  % registered points
tLMY_g = cpd_transform_nn(LMY,Transform_g,Normal_g);  % warping landmarks too

% plot the results
PtsPlot_tmp(X,Y,   LMX,LMY,   'Before registration');
PtsPlot_tmp(X,tY,  LMX,tLMY,  'CPD registered');
PtsPlot_tmp(X,tY_g,LMX,tLMY_g,'Guided CPD');



