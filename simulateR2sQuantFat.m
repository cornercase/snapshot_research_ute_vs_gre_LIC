%function [] = simulateR2sQuantFat()
%function to test the effects of echo time selection on quantitation

newpath = [pwd '/code/wood'];
if isempty(strfind(path(),'/code/wood'))
    init_path = path();
    %matlabpath([newpath ':' init_path]);
    path(newpath,path);
    path('~/repos/research_code/Iron',path);
end



TE = [0.19, 0.23, 0.35, 0.60, 0.85, 1.0, 2.0]./1000;
TE = linspace(0.76,8.8,16)./1000;

B0 = 3;
ff = [0:0.01:0.2];
lic = [0.5:0.5:45];
resultLIC = zeros(length(ff),length(lic),2) -1;
actLIC = repmat(lic,length(ff),1,2);
hNoPd.setMinT2Val = 1/4000;
hNoPd.Technique = 'ExpC';
hNoPd.usePdEst = 'no';
method=hNoPd.Technique;
for TEidx=1:2
    if TEidx==1; TE = [0.19, 0.23, 0.35, 0.60, 0.85, 1.0, 2.0]./1000;
    else TE = linspace(0.76,8.8,16)./1000;
    end
    parfor ffIdx = 1:length(ff)
        tempRow = zeros(1,length(lic));
        for licIdx = 1:length(lic)

            r2s = getLIC(lic(licIdx),'LIC','3T','expc','R2*');
            sig = makeFatWaterDecaySignal(TE,r2s,ff(ffIdx),0,B0,0);
            noise = complex(randn(1,length(TE))*0.01,randn(1,length(TE))*0.01);
            sig = sig + noise;


            [liverPDEa,liverT2b,res]=fastlsMat2(TE,sig,.00019);
            estR = median(1./liverT2b);
            [S0t,T2t,Ct,Rest,ext] = NewFit2(TE,abs(sig),estR,method,hNoPd,hNoPd);
            if 1==0
                figure(5);clf;
                plot(TE,real(sig),'b*');hold on;
                plot(TE,imag(sig),'g*');
                plot(TE,abs(sig),'*r');
                hold on;
                plot(TE,S0t*exp(-TE./T2t)+Ct,'r');
                hold off;
                title(sprintf('LIC = %3.1f   FF = %0.2f',lic(licIdx),ff(ffIdx)));
                drawnow;
                pause;
            end
            %resultLIC(ffIdx,licIdx) = getLIC(1/T2t,'R2*','3T','expc');
            tempRow(licIdx) = getLIC(1./T2t,'R2*','3T','expc');
        end
        resultLIC(ffIdx,:,TEidx) = tempRow;
    end
end
%imagesc(lic,ff,(resultLIC-actLIC)./actLIC);
%%

h = 1/9*ones(5);
LICerror = 100*(resultLIC-actLIC)./actLIC;
LICdiff = resultLIC-actLIC;
smoothLICerror = filter2(h,LICerror(:,:,1));
smoothLICerror(:,:,2) = filter2(h,LICerror(:,:,2));
smoothLICdiff = filter2(h,LICdiff(:,:,1));
smoothLICdiff(:,:,2) = filter2(h,LICdiff(:,:,2));
%contour3(lic,ff,smoothLICerror,1000);
figure(1);
subplot(1,2,1);
surf(lic,ff,smoothLICerror(:,:,1));
title('Ute Fits');
subplot(1,2,2);
surf(lic,ff,smoothLICerror(:,:,2));
title('GRE Fits')
colormap('parula');
xlabel('Liver iron');
ylabel('Fat fraction');
zlabel('Error in R2* iron estimate [%]');
zlim([-10 100]);
caxis([-10 100]);
%end %function simulateR2sQuantFat

figure(3);clf;
plot(fit(lic(4:end)',smoothLICerror(  1,4:end,1)','poly4'),'b'); hold on; 
plot(fit(lic(4:end)',smoothLICerror( 11,4:end,1)','poly4'),'b-.')
plot(fit(lic(4:end)',smoothLICerror(end,4:end,1)','poly4'),'b--')
plot(fit(lic(4:end)',smoothLICerror(  1,4:end,2)','poly4'),'r'); hold on; 
plot(fit(lic(4:end)',smoothLICerror( 11,4:end,2)','poly4'),'r-.')
plot(fit(lic(4:end)',smoothLICerror(end,4:end,2)','poly4'),'r--')
xlim([10 45]);


figure(2);clf;
plot(lic,smoothLICerror(  1,:,1),'b'); hold on; 
plot(lic,smoothLICerror( 6,:,1),'b-.')
plot(lic,smoothLICerror( 11,:,1),'b-.')
plot(lic,smoothLICerror(end,:,1),'b--')
plot(lic,smoothLICerror(  1,:,2),'r'); hold on; 
plot(lic,smoothLICerror( 6,:,2),'r-.')
plot(lic,smoothLICerror( 11,:,2),'r-.')
plot(lic,smoothLICerror(end,:,2),'r--')
legend('No Fat, UTE', '10% PDFF, UTE','20% PDFF, UTE',...
    'No Fat, GRE','10% PDFF, GRE','20% PDFF, GRE');
xlabel('Actual LIC [mg/g]')
ylabel('LIC Estimate Error [%]');
ylim([-45 45]);


%%
th = figure(4);clf;


idx=[(1:3:90) 90];
plot(lic(idx),smoothLICdiff(  1,idx,1),'b','LineWidth',2); 
hold on; 
plot(lic(idx),smoothLICdiff( 6,idx,1),'b--','LineWidth',2);
plot(lic(idx),smoothLICdiff( 11,idx,1),'b--','LineWidth',2);
plot(lic(idx),smoothLICdiff(end,idx,1),'b:','LineWidth',2);
plot(lic(idx),smoothLICdiff(  1,idx,2),'r','LineWidth',2); 
hold on; 
plot(lic(idx),smoothLICdiff( 6,idx,2),'r--','LineWidth',2);
plot(lic(idx),smoothLICdiff( 11,idx,2),'r--','LineWidth',2);
plot(lic(idx),smoothLICdiff(end,idx,2),'r:','LineWidth',2);
hl = legend('      No Fat, UTE', '  5% PDFF, UTE','10% PDFF, UTE','20% PDFF, UTE',...
    '      No Fat, GRE', '  5% PDFF, GRE','10% PDFF, GRE','20% PDFF, GRE');
set(hl,'FontName','Times New Roman','FontSize',10,'Position',[0.6850    0.6022    0.2    0.3017]);
hx = xlabel('Actual LIC [mg/g]','Interpreter','latex');
set(hx,'FontSize',14);
set(gca,'FontSize',14,'FontName','Times New Roman');
ylabel('LIC Estimate Error [\%]','Interpreter','Latex')
ylim([-15 30]);
xlim([2.5 40]);

set(th,'PaperSize',[3.42 3.42*420/560]*2)
set(th,'PaperPosition',[0 0 3.42*2 2*3.42*420/560]);
saveas(th,['figs/pub2-fatR2s'],'epsc');
saveas(th,['figs/pub2-fatR2s'],'fig');
