function [S0,R2,Noise_est,Res] = fitexp(t,s)
% [S0,T2,C,Res] = fitexp(t,s)
%
% Fit an exponential + constant to the real signal, s(t)
%
% ARGS :
% t = time vector in seconds
% s = S(t) in arbitrary units
%
% RETURNS :
% S0 = s(t = 0) from model fit
% T2 = T2 relaxation time of the exponential component
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : CHLA, Los Angeles
% DATES  : 07/16/2002 JMT Adapt from fitgauss.m

% Verbosity flag
global verbose
% verbose =0;
if ~exist('verbose','var')
    verbose = 0;
end

% Initialize return arguments
sd = [];

if ~isreal(s)
  fprintf('s(t) must be real for this function\n');
  return
end

% Flatten t and s
t = t(:);
s = s(:);

% Initial parameter estimates
S0_est = s(1);
R2_est = -log(s(1)/s(2))/(t(1)-t(2));
R2_est = min(R2_est,4000); T2_est = max(R2_est,10); % 'Limit to 10 - 4000'
Noise_est=s(length(s));

% Setup optimization parameters
options = optimset('lsqcurvefit');
options.Display = 'off';
options.TolFun = 1e-6;
options.TolX = 1e-6;
options.MaxIter = 100;

% Initial parameter vector
x0 = [S0_est R2_est Noise_est];

% Parameter constraints
lb = [0   0  0];
ub = [inf inf inf ];

% Start optimization
[x_fit,Res] = lsqcurvefit('rexp',x0,t,s,lb,ub,options);

% Calculate fitted function values
s_fit = rexp(x_fit,t);

% Calculate return values
S0 = x_fit(1);
R2 = x_fit(2);
Noise_est = x_fit(3);

% Optional verbose output and graph
if verbose
  
  plot(t,s_fit,t,s,'o');
  xlabel('Time (s)');
  drawnow; pause;
  
  fprintf('Fit parameters:\n');
  fprintf('  S0 : %g\n', S0);
  fprintf('  R2 : %g\n', R2);
end