function y = exp(x,t)
% y = expc(x,t)
%
% Exponential decay + constant
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
% DATES  : 07/16/2002 JMT Adapt from gauss.m

y = x(1) * exp(-t * x(2));
SNR = y./x(3);
bias = x(3)*(0.0083709*SNR.^4 -0.10802*SNR.^3 + 0.50468*SNR.^2 - 1.032 * SNR + 0.79145);
bias(SNR>3) = 0;
y=y+bias;