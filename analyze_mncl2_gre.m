% Driver script
% UTE vs GRE @ 3T
newpath = [pwd '/code/wood'];
if isempty(strfind(path(),'/code/wood'))
    init_path = path();
    %matlabpath([newpath ':' init_path]);
    path(newpath,path);
    path('~/repos/research_code/Iron',path);
end

%% generate paths
imstack = zeros(288,288,16);
TEs = [];
for n=1:16
    offset = 62;
    tp = sprintf('20170104_phantom_tfe/DICOM/IM_%04i',n+offset);
    [im TE dcmnfo] = readDicomSeries(tp);
    %imagesc(im);
    %title(tp);
    imstack(:,:,n) = im;
    TEs(n) = TE;
end
load('20170104_phantom_tfe/DICOM/rois.mat');
%% run fits
imstack_size_orig = size(imstack);
imstack = reshape(imstack,[],imstack_size_orig(3));

fitString = 'exp1_gre';

fprintf(' %s',fitString);
resgre = [];


hNoPd.Technique = 'ExpC';
hNoPd.usePdEst = 'no';
method=hNoPd.Technique;
[liverPDEa,liverT2b,res]=fastlsMat2(TEs,imstack,.002);
estR = median(1./liverT2b);
S0 = ones(max(size(im)),1); T2 = S0; C = S0; Res = S0;
try
    matlabpool 4;
catch err
end
parfor m = 1:max(size(imstack))
    [S0t,T2t,Ct,Rest,ext] = NewFit2(TEs,imstack(m,:),estR,method,hNoPd,hNoPd);
    S0(m) = S0t; T2(m) = T2t; C(m) = Ct; Res(m) = Rest;
end
matlabpool close;
resgre.S0 = S0;
resgre.T2 = T2;
resgre.C  = C;
resgre.Res  = Res;
resgre.fitString = fitString;
%save('results_phantom_gre','resgre','imstack_size_orig','rois');


%% 
r2s = [];
mncl2 = manganese_chest_phantom;
for n=1:length(mncl2);
    roiT = rois{n};
    roiT = reshape(roiT,288*288,1);
    r2s(n) = 1./median(T2(find(roiT)));
end

plot(mncl2,r2s,'*');
    
    
    


    