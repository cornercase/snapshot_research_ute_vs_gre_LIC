%Driver script
% UTE vs GRE @ 3T
newpath = [pwd '/code/wood'];
if ~strfind(matlabpath(),newpath)
    init_path = matlabpath();
    newpath = [pwd '/code/wood'];
    matlabpath([newpath ':' init_path]);
end

%generate paths
exams = genImagePathStructs('./files/','file_subpaths.txt');
try matlabpool 3; catch err; end
%run fits
for n=1:length(exams)
    resFile = matfile(exams{n}.savePath);
    completedFits = '';
    if ~exist(resFile.Properties.Source(1:end-11),'dir')
        mkdir(resFile.Properties.Source(1:end-11));
    end
    try
        completedFits = resFile.completedFits;
    catch err
        resFile.Properties.Writable = true;
        resFile.completedFits = completedFits;
    end
    
    hNoPd.Technique = 'ExpC';
    hNoPd.usePdEst = 'no';
    method=hNoPd.Technique;
    fprintf('Run %i', n);
    if max(size(strfind(completedFits,'ute1')))==0
        fprintf(' ute');
        resute = [];
        [im te dcminfo] = prepScan(exams{n}.ute);
        [liverPDEa,liverT2b,res]=fastlsMat2(te,im,.0019);
        estR = median(1./liverT2b);
        S0 = ones(max(size(im)),1); T2 = S0; C = S0; Res = S0;
        parfor m = 1:max(size(im))
            [S0t,T2t,Ct,Rest,ext] = NewFit2(te,im(m,:),estR,method,hNoPd,hNoPd);
            S0(m) = S0t; T2(m) = T2t; C(m) = Ct; Res(m) = Rest;
        end
        resute.S0 = S0;
        resute.T2 = T2;
        resute.C  = C;
        resute.Res  = Res;
        resFile.Properties.Writable = true;
        resFile.resute = resute;
        completedFits = [completedFits ' ute1'];
    end
    
    
    %gre = struct('im',im,'te',te,'dcminfo',dcminfo);
    if max(size(strfind(completedFits,'gre1')))==0
        fprintf(' gre');
        resgre = [];
        [im te dcminfo] = prepScan(exams{n}.gre);
        [liverPDEa,liverT2b,res]=fastlsMat2(te,im,.002);
        estR = median(1./liverT2b);
        S0 = ones(max(size(im)),1); T2 = S0; C = S0; Res = S0;
        parfor m = 1:max(size(im))
            [S0t,T2t,Ct,Rest,ext] = NewFit2(te,im(m,:),estR,method,hNoPd,hNoPd);
            S0(m) = S0t; T2(m) = T2t; C(m) = Ct; Res(m) = Rest;
        end
        resgre.S0 = S0;
        resgre.T2 = T2;
        resgre.C  = C;
        resgre.Res  = Res;
        resFile.Properties.Writable = true;
        resFile.resgre = resgre;
        completedFits = [completedFits ' gre1'];
    end
    if ~strmatch(completedFits,resFile.completedFits)
        resFile.Properties.Writable = true;
        resFile.completedFits = completedFits;
    end
    fprintf('\n');
end
matlabpool close;