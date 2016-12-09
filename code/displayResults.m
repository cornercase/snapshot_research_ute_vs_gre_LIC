function [R2out pLIC scanType] = displayResults(ps)
    R2out = [];
    pLIC = zeros(1,length(ps))-1;
    for n=1:length(ps)
        R2out(end+1,1:6) =[ mean(ps{n}.SR.PD.T2(:,2)), ...
                            mean(ps{n}.SR.PD.T2(:,1)), ...
                            mean(ps{n}.SR.noPD.T2(:)), ...
                            mean(ps{n}.ER.PD.T2(:,2)), ...
                            mean(ps{n}.ER.PD.T2(:,1)), ...
                            mean(ps{n}.ER.noPD.T2(:))];
        if ~isempty(ps{n}.dbLIC)
            pLIC(n) = max(ps{n}.dbLIC);
        end
        %ps{n}.roiE
        if strfind(ps{n}.roiE,'4545_dc')
            scanType(n) = 2;
        else
            scanType(n) = 1;
        end
                        %displayOneComparison(ps{n});
        %pause;
    end
    R2out = 1./R2out;

end





function [] = displayOneComparison(p)
    
global fT2;
global fS0;
fT2 = figure(10);
fS0 = figure(11);

plotStuff(p.ER.PD,p.ROI.liver,1);
plotStuff(p.ER.noPD,p.ROI.liver,2);

tROI = load(p.roiS);
p.ROI = tROI.roi;

plotStuff(p.SR.PD,p.ROI.liver,3);
plotStuff(p.SR.noPD,p.ROI.liver,4);
labelAxes();

end

function [] = plotStuff(r,roi,subind);
    global fT2;
    global fS0;
    [S0map T2map Cmap ResMap] =...
        reshapeToLiverMap(r.S0,r.T2,r.C,r.Res,roi,false);
    figure(fT2); subplot(2,2,subind); imagesc(1./T2map .* roi); ...
        caxis([0 600]);
    figure(fS0);subplot(2,2,subind); imagesc(S0map .* roi);
end

function [] = labelAxes()
    global fT2;
    global fS0;
    
    fList(1) = fT2;
    fList(2) = fS0;
    for h = fList
        figure(h);
        subplot(2,2,1);
        ylabel('Eamon');
        title('PD Estimator');
        
        subplot(2,2,2);
        title('No PD Estimator');
        
        subplot(2,2,3);
        ylabel('John');
    end
end




