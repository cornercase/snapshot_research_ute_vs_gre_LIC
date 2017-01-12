function [S0,T2,C,Res,ex] = NewFit2(t,s,estR,method,handles,eamonTemp)
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


%TechniqueString=get(handles.Technique,'String'); Technique=TechniqueString{get(handles.Technique,'Value')};
%NoiseSource=get(handles.NoiseSource,'Value');
TechniqueString = handles.Technique;

% Verbosity flag
global verbose
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
t = double(t(:));
s = double(s(:));
N=length(s);

estR=double(max(estR,10)); estR=double(min(estR,3000)); % protect against bad initial estimates
TEmax=1.6/estR;
TruncP=max(sum(t<TEmax),2);  % keep at least 2 coefficients
S0_est=mean(s(1:TruncP).*exp(t(1:TruncP).*estR));

switch method
    case 'TruncExp'
         keep=TruncP; C_est=0;
    case 'ExpC'
        S0_est=mean(s(1:TruncP).*exp(t(1:TruncP).*estR));
        C_est=mean(abs(s-S0_est*exp(-estR*t)));
        ub(3)=5*C_est; lb(3)=0; keep=length(t);
    case 'Exp'
        keep=length(t); C_est=0;
    case 'Exp(MaxC)'
        S0_est=mean(s(1:TruncP).*exp(t(1:TruncP).*estR));
        C_est=mean(abs(s-S0_est*exp(-estR*t)));
        ub(3)=5*C_est; lb(3)=0; keep=length(t);
    case 'TwoStep'
        S0_est=mean(s(1:TruncP).*exp(t(1:TruncP).*estR));
        C_est=mean(abs(s-S0_est*exp(-estR*t)));
        ub(3)=5*C_est; lb(3)=0; keep=length(t);
    otherwise
        error('Technique Type Not Recognized in NewFit')
end
% Initial parameter vector
x0=[S0_est,1/estR,C_est];

% Setup optimization parameters
options = optimset('lsqcurvefit');
options.Display = 'off';
options.TolFun = 1e-6;
options.TolX = 1e-6;
options.MaxIter = 100;


% Parameter constraints
if strcmp(eamonTemp.usePdEst,'yes')
    lb(1:2)=[eamonTemp.S0est*.90,0];
    ub(1:2)=[eamonTemp.S0est*1.1,1/10];
    x0(1) = eamonTemp.S0est;
else
    lb(1:2)=[s(1),1/3000];
    ub(1:2)=[s(1)*4,1/10];    
end
if isfield(eamonTemp,'setMinT2Val')
    lb(2) = eamonTemp.setMinT2Val;
end



% Start optimization
try
    if strcmp(method,'TruncExp') | estR < 100 | strcmp(method,'Exp')
        [x_fit,Res] = lsqcurvefit('expF',x0(1:2),t(1:keep),s(1:keep),lb(1:2),ub(1:2),options);
    else
        if strcmp(method,'Exp(MaxC)')
            [x_fit,Res] = lsqcurvefit('expmaxc',x0,t,s,lb,ub,options);
        else
            %lb
            %ub
            [x_fit,Res] = lsqcurvefit('expc',x0,t,s,lb,ub,options);
        end
    end
    if strcmp(method,'TwoStep')
        if length(x_fit)>2
            if strcmp('TwoStep',Technique) && NoiseSource == 0
                sigma = get(handles.NoiseSource,'Userdata');
            else
                sigma = sqrt(2)*x_fit(3);
            end
            SNR=expF(x_fit(1:2),t)/sigma;
            SNR=min(SNR,2.5);
            bias=sigma*(-0.058*SNR.^3+0.41*SNR.^2-0.98*SNR+0.79);
            [x_fit,Res] = lsqcurvefit('expc',x0,t,s-bias,lb,ub,options);
        end
    %    if length(x_fit)>2
    %        index=find(s<x_fit(3));
    %    else
    %        index=[];x_fit(3)=0;
    %    end
    %    if length(index)==0
    %        keep=length(s);
    %    else
    %        keep=max(index(1)-1,2);
    %    end
    %    [x_fit,Res] = lsqcurvefit('expF',x0(1:2),t(1:keep),sqrt(abs(s(1:keep).^2-2*x_fit(3)^2)),lb(1:2),ub(1:2),options);
    end
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
    ex=[];
catch exC
    S0 = -1;
    T2 = -1;
    C = -1;
    s_fit=-1;
    Res = -1;
    ex = exC;
end
    
% Optional verbose output and graph
if verbose
  
  plot(t,s_fit,t,s,'o');
  xlabel('Time (s)');
  drawnow; pause;
  
  fprintf('Fit parameters:\n');
  fprintf('  S0 : %g\n', S0);
  fprintf('  T2 : %g\n', T2);
  fprintf('  C  : %g\n', C);
  
end