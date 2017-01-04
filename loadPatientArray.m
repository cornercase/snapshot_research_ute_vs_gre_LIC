function [out] = loadPatientArray(id,varargin)
% Brief function to individually examine patient data and do quick fits
% out = loaoPatientArray(id,varargin)
%   <id> is integer
%   overlayPlotHandle is handle to give GRE and UTE results overlayed
%
p=inputParser;
p.addRequired('id');
p.addParameter('overlayPlotHandle',[]);
p.parse(id,varargin{:});

if ~isempty(p.Results.overlayPlotHandle) && p.Results.overlayPlotHandle == -1;
    oph = id;
else
    oph = p.Results.overlayPlotHandle;
end

exams = genImagePathStructs('./files/','file_subpaths.txt');
map=containers.Map();
for n=1:length(exams)
    map(exams{n}.patID)=n;
end



[im te dcminfo] = prepScan(exams{map(sprintf('%03i',id))}.ute);
ute = struct('im',im,'te',te,'dcminfo',dcminfo);
[im te dcminfo] = prepScan(exams{map(sprintf('%03i',id))}.gre);
gre = struct('im',im,'te',te,'dcminfo',dcminfo);

out=struct('ute',ute,'gre',gre);

if ~isempty(oph)
    overlayPlot(out,oph,sprintf('%03i',id));
end
end


function [] = overlayPlot(out,handle,id)
    figure(handle);
    
    clf;
    greSig = sum(out.gre(1).im,1);
    uteSig = sum(out.ute(1).im,1);
    
    greTE = out.gre(1).te;
    uteTE = out.ute(1).te;
    t = 0:0.00001:max(greTE);
    [gs gt2 gc] = quickFit(greSig,greTE);
    [us ut2 uc] = quickFit(uteSig,uteTE);
    
    greSig = greSig ./ gs;
    uteSig = uteSig ./ us;
    
    scatter(greTE,greSig,'r^');
    hold on;
    plot(t,exp(-t./gt2)+gc/gs,'r');
    scatter(uteTE,uteSig,'b+');
    plot(t,exp(-t./ut2)+uc/us,'b');
    legend('Normalized GRE Samp',...
        sprintf('GRE Fit\nT2 = %4.4f C = %4.4f', gt2, gc./gs),...
        'Normalized UTE Samp',...
        sprintf('UTE Fit\nT2 = %4.4f C = %4.4f',ut2, uc./us),...
        'Location','Northeast');
    xlabel('Time (seconds)');
    ylabel('Sig intensity (arbitrary, normalized)');
    title(sprintf('Comparison of Samples and Fits, pat %s', id));
    
    
end


function [S0,T2,C] = quickFit(s,t)

    hNoPd.Technique = 'ExpC';
    hNoPd.usePdEst = 'no';
    method=hNoPd.Technique;
    
    [liverPDEa,liverT2b,res]=fastlsMat2(t,s,.0019);
    estR = median(1./liverT2b);
    [S0,T2,C,Res,ext] = NewFit2(t,s,estR,method,hNoPd,hNoPd);
    
end