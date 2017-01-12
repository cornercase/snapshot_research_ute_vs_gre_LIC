function [S0,T2,C,Res] = NewFit(t,s,initial)
% [S0,T2,C,Res] = NewFit(t,s,estR,method)
%
% Fit a model to the real signal, s(t)
%
% ARGS :
% t = time vector in seconds
% s = S(t) in arbitrary units
% estR = estimated Relaxivity
% method = Exponential + Constant (ExpC) or Truncated Exponential (TruncExp)
%
% RETURNS :
% S0 = s(t = 0) from model fit
% T2 = T2 relaxation time of the exponential component
% C  = constant signal offset
% R  = Residual
%
% AUTHOR : Mike Tyszka, Ph.D. and John Wood MD, PhD
% PLACE  : CHLA, Los Angeles
% DATES  : 04/21/2011 JMT Adapt from fitgauss.m and JW from fit_exp_const

% Verbosity flag


% Initialize return arguments
sd = [];

if ~isreal(s)
  fprintf('s(t) must be real for this function\n');
  return
end

% Flatten t and s
t = double(t(:));
s = double(s(:));
N=length(s);

S0_est=(1.548+.0002*initial(2)-2e-08*initial(2).^2)*initial(1);
lb(1)=S0_est-.1*initial(1);  ub(1)=S0_est+.1*initial(1);
lb(2)=1/3000;     ub(2)=1/10;
lb(3)=0;          ub(3)=initial(3)+eps;

% Initial parameter vector
x0=[S0_est,1/initial(2),initial(3)];

% Setup optimization parameters
options = optimset('lsqcurvefit');
options.Display = 'off';
options.TolFun = 1e-6;
options.TolX = 1e-6;
options.MaxIter = 100;


% Start optimization
[x_fit,Res] = lsqcurvefit('expc',x0,t,s,lb,ub,options);


% Calculate fitted function and return values
S0 = x_fit(1);
T2 = x_fit(2);
if length(x_fit)>2
    C  = x_fit(3);
    s_fit = expc(x_fit,t);
else
    C = 0;
    s_fit = expF(x_fit,t);
end
