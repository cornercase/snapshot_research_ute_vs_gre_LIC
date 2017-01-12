% Takes (TE, signal, TEMin)
% Returns  A = signal intensity, b = T2/T2* decay term (not R2)
% IE, it solves y = Ae^(-TE/T2), returns [A, T2, residual]

function [a,b,res]=fastls(x,data,TeMin)
ind=find(x>TeMin);
TeMinInd=max(ind(1),2) ;
y=log(data);
[Nrows,N]=size(data);   
xm=cumsum(x)./[1:N];
Nramp=repmat([1:N],[Nrows,1]); % these arrays are now [Nrows,N]
ym=cumsum(y,2)./Nramp;    % these arrays are now [Nrows,N]
%%yi = find(min(y,[],2)>0);
%ym= ym(yi,:);
%y = y(yi,:);
%data = data(yi,:);
for i=2:TeMinInd
    b(:,i)=((x(1:i)-xm(i))*(y(:,1:i)-repmat(ym(:,i),[1,i]))')./((x(1:i)-xm(i))*(x(1:i)-xm(i))');
end
TEmax=(-1.6./b(:,TeMinInd)); TEmax(isnan(TEmax))=.001;
TEmax=median(TEmax);
cutoff=max(length(find(x<TEmax))-1,2);
b=((x(1:cutoff)-xm(cutoff))*(y(:,1:cutoff)-repmat(ym(:,cutoff),[1,cutoff]))')./((x(1:cutoff)-xm(cutoff))*(x(1:cutoff)-xm(cutoff))');
a=ym(:,cutoff)-b'*xm(cutoff);
res=sum((data-exp(repmat(a,[1,N])+b'*x)).^2,2);
a=real(exp(a)); b=max(0,real(-1./b));
    