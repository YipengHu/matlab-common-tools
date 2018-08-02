%  examples_guidedcpd_120709

% compile the c code first:
%   mex cpd_P.c
%   mex cpd_P_guided.c
% alternatively, rename the m files:
%   cpd_P_m.m -> cpd_P.m
%   cpd_P_guided_m.m -> cpd_P_guided.m


%%%%%%%%%%%%%%%%%%%%%%%%%
% example 01 - prostate %
%%%%%%%%%%%%%%%%%%%%%%%%%
% load data
clear all; close all
load('./data_ex01_prostate');

% normal nonrigid CPD
opt.method = 'nonrigid';
opt.viz = true;
[Transform,Normal] = cpd_register_guided(X,Y,opt);
tY = cpd_transform_nn(Y,Transform,Normal);  % registered points
topt.gY = cpd_transform_nn(opt.gY,Transform,Normal);  % warping landmarks too

% landmark-guided CPD
opt.method = 'nonrigid_guided';
opt.viz = true;
opt.ss2 = 1e-3;  % hyper parameter for landmarks
[Transform_g,Normal_g] = cpd_register_guided(X,Y,opt);
tY_g = cpd_transform_nn(Y,Transform_g,Normal_g);  % registered points
topt.gY_g = cpd_transform_nn(opt.gY,Transform_g,Normal_g);  % warping landmarks too

% plot the results
SrfPlot_tmp(X,Y,   opt.gX,opt.gY,   trix,triy,1,'Before registration');
SrfPlot_tmp(X,tY,  opt.gX,topt.gY,  trix,triy,1,'CPD registered');
SrfPlot_tmp(X,tY_g,opt.gX,topt.gY_g,trix,triy,1,'Guided CPD');


