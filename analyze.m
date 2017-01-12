%Driver script
% UTE vs GRE @ 3T
newpath = [pwd '/code/wood'];
if isempty(strfind(path(),'/code/wood'))
    init_path = path();
    %matlabpath([newpath ':' init_path]);
    path(newpath,path);
    path('~/repos/research_code/Iron',path);
end

%generate paths
exams = genImagePathStructs('./files/','file_subpaths.txt');
try matlabpool 10; catch err; end
%run fits
for n=1:length(exams)
    
    resFile = matfile(exams{n}.savePath,'Writable',true);
    if ~exist(resFile.Properties.Source(1:end-11),'dir')
        mkdir(resFile.Properties.Source(1:end-11));
    end
    
    
    if min(size(whos(resFile,'resCell')))==0
        resFile.resCell = cell(0,0);
    end
    completedFits = '';
    
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
    fitString = 'exp1_ute';
    do1 = max(size(strfind(completedFits,fitString)))==0;
%    do2 = ~isempty(strfind(exams{n}.savePath,'3T_023BC'));
%    do3 = ~isempty(strfind(exams{n}.savePath,'3T_033AT'));
%    do4 = ~isempty(strfind(exams{n}.savePath,'3T_063_LS'));
    if do1
        hNoPd.setMinT2Val = 1/4000;
        fprintf(' %s',fitString);
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
        resute.fitString = fitString;
        resFile.Properties.Writable = true;
        resCell=resFile.resCell;
        resCell{end+1} = resute;
        resFile.resCell = resCell;
        completedFits = [completedFits ' ' fitString];
    end
    
    

    fitString = 'exp1_gre';
    if max(size(strfind(completedFits,fitString)))==0
        fprintf(' %s',fitString);
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
        resgre.fitString = fitString;
        resCell=resFile.resCell;
        resCell{end+1} = resgre;
        resFile.resCell = resCell;
        resFile.Properties.Writable = true;
        resFile.examdate = dcminfo{1}.AcquisitionDate;
       completedFits = [completedFits ' ' fitString];
    end
    
    fitString = 'rexp1_ute';
    if max(size(strfind(completedFits,fitString)))==0
        fprintf(' %s',fitString);
        resute = [];
        [im te dcminfo] = prepScan(exams{n}.ute);
        
        S0 = ones(max(size(im)),1); T2 = S0; Noise = S0; Res = S0;
        parfor m = 1:max(size(im))
            [S0t,T2t,Noiset,Rest] = rfitexp(te,im(m,:));
            S0(m) = S0t; T2(m) = T2t; Noise(m) = Noiset; Res(m) = Rest;
        end
        resute.S0 = S0;
        resute.T2 = T2;
        resute.Noise  = Noise;
        resute.Res  = Res;
        resute.fit = fitString;
        
        fprintf(' %s',fitString);
        
        resCell=resFile.resCell;
        resCell{end+1} = resute;
        resFile.resCell = resCell;
        
        completedFits = [completedFits ' ' fitString];
    end
    
    fitString = 'rexp1_gre';
    if max(size(strfind(completedFits,fitString)))==0
        fprintf(' %s',fitString);
        resgre = [];
        [im te dcminfo] = prepScan(exams{n}.gre);
        S0 = ones(max(size(im)),1); T2 = S0; Noise = S0; Res = S0;
        parfor m = 1:max(size(im))
            [S0t,T2t,Noiset,Rest] = rfitexp(te,im(m,:));
            S0(m) = S0t; T2(m) = T2t; Noise(m) = Noiset; Res(m) = Rest;
        end
        resgre.S0 = S0;
        resgre.T2 = T2;
        resgre.Noise  = Noise;
        resgre.Res  = Res;
        resgre.fit = fitString;
        resFile.Properties.Writable = true;
        resCell=resFile.resCell;
        resCell{end+1} = resgre;
        resFile.resCell = resCell;
    
        resFile.Properties.Writable = true;
        resFile.examdate = dcminfo{1}.AcquisitionDate;
        completedFits = [completedFits ' ' fitString];
    end
    
    fitString = 'rexp1_lowfield';
    if 1==0 %max(size(strfind(completedFits,fitString)))==0
        fprintf(' %s',fitString);
        [im te dcminfo] = prepScan(exams{n}.clinical);
        
        S0 = ones(max(size(im)),1); T2 = S0; Noise = S0; Res = S0;
        parfor m = 1:max(size(im))
            [S0t,T2t,Noiset,Rest] = rfitexp(te,im(m,:));
            S0(m) = S0t; T2(m) = T2t; Noise(m) = Noiset; Res(m) = Rest;
        end
        res.S0 = S0;
        res.T2 = T2;
        res.Noise  = Noise;
        res.Res  = Res;
        res.fit = fitString;
        resFile.Properties.Writable = true;
        resCell=resFile.resCell;
        resCell{5} = res;
        resFile.resCell = resCell;
    
        resFile.Properties.Writable = true;
        
        %completedFits = [completedFits ' ' fitString];
    end
    
    
    if ~strncmp(completedFits,resFile.completedFits,max(size(completedFits)))
        resFile.Properties.Writable = true;
        resFile.completedFits = completedFits;
    end
    fprintf('\n');
end
matlabpool close;