function y=makeFatWaterDecaySignal(TE,R2s,fatFraction,B0,Field,sigma,a,f)
    W = 1-fatFraction;
    F = fatFraction;
if nargin < 9
    a(1)= .047;     f(1)=Field*42.58*-0.6;
    a(2)= 0.039;    f(2)=Field*42.58*0.5;
    a(3)= 0.006;    f(3)=Field*42.58*1.95;
    a(4)= 0.12;     f(4)=Field*42.58*2.6;
    a(5)= 0.70;     f(5)=Field*42.58*3.4;
    a(6)= 0.088;    f(6)=Field*42.58*3.8;
end
unitfat=a(1)*exp(j*2*pi*f(1)*TE)+a(2)*exp(j*2*pi*f(2)*TE)+a(3)*exp(j*2*pi*f(3)*TE);
unitfat=unitfat+a(4)*exp(j*2*pi*f(4)*TE)+a(5)*exp(j*2*pi*f(5)*TE)+a(6)*exp(j*2*pi*f(6)*TE);
y=exp((-R2s+j*B0)*TE).*(W + F*unitfat);


end %function makesignal