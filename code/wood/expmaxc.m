function y = expmaxc(x,t)
% y = expmaxc(x,t)
%
% Set to the max (Exponential decay, constant). 
% This allows the constant to correct for the noise floor without biasing
% the fit above the floor. 
%
% ARGS :
% x = argument vector [S0 T2 C]
% t = time vector in seconds
%
% RETURNS :
% y = exponential + constant function of t
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : CHLA, Los Angeles
% DATES  : 07/16/2002 JMT Adapt from gauss.m, adapted by JW 5/23/2013

y = max(x(1) * exp(-t / x(2)), x(3));