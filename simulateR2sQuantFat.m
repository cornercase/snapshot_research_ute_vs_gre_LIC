%function [] = simulateR2sQuantFat()
%function to test the effects of echo time selection on quantitation

newpath = [pwd '/code/wood'];
if isempty(strfind(path(),'/code/wood'))
    init_path = path();
    %matlabpath([newpath ':' init_path]);
    path(newpath,path);
    path('~/repos/research_code/Iron',path);
end



TE = [0.19, 0.23, 0.35 ,0.60, 0.85, 1.0, 2.0]./1000;
B0 = 3;
ff = [0:0.01:0.2];
lic = [0.5:0.5:45];
resultLIC = zeros(length(ff),length(lic)) -1;
actLIC = repmat(lic,length(ff),1);
for ffIdx = 1:length(ff)
    for licIdx = 1:length(lic)
        hNoPd.Technique = 'ExpC';
        hNoPd.usePdEst = 'no';
        method=hNoPd.Technique;
        r2s = getLIC(lic(licIdx),'LIC','3T','expc','R2*');
        sig = makeFatWaterDecaySignal(TE,r2s,ff(ffIdx),0,B0,0);
        noise = complex(randn(1,length(TE))*0.07,randn(1,length(TE))*0.07);
        sig = sig + noise;
        
        hNoPd.setMinT2Val = 1/4000;
        [liverPDEa,liverT2b,res]=fastlsMat2(TE,sig,.00019);
        estR = median(1./liverT2b);
        [S0t,T2t,Ct,Rest,ext] = NewFit2(TE,abs(sig),estR,method,hNoPd,hNoPd);
        if 1==0
            plot(TE,abs(sig),'*r');
            hold on;
            plot(TE,S0t*exp(-TE./T2t),'r');
            hold off;
            title(sprintf('LIC = %3.1f   FF = %0.2f',lic(licIdx),ff(ffIdx)));
            drawnow;
            %pause;
        end
        resultLIC(ffIdx,licIdx) = getLIC(1./T2t,'R2*','3T','expc');
    end
end

imagesc(lic,ff,(resultLIC-actLIC)./actLIC);

%end %function simulateR2sQuantFat

