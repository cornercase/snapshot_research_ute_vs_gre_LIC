%% prep file array
%filesToProc;
if 1==1
if ~exist('filesToProc')
    filesToProc = struct;

    folder = '/Volumes/data/3T/';
    patients = dir([folder '3T_*']);

    %    imageTypes{1} = 'tse4545_dc_';
    imageTypes{1} = '4545_dc_';
    imageTypes{2} = 'T2W_TSE_';
    imageTypes{3} = 'tse4545_dc_';
    contrastTypes{1} = 'T2';
    
    %imageTypeInd = 2;

    for n=1:length(patients)
        patient = patients(n);

        addPat = 0;
        %imagesPath = cell(2,1);
        b = getAllFiles([folder patient.name]);
        %ind = strfind(b,'ROI/liver-000');
        for imageTypeInd = 1:2
            regexTerm = [imageTypes{imageTypeInd}];
            ind = regexp(b,regexTerm);
            
            if ~(isempty(cell2mat(ind)))
                addPat = 1;
                roiInd = find(not(cellfun('isempty', ind)));
                temp = strsplit(cell2mat(b(roiInd(1))),'/');
                imagesPath.basePath = strjoin(temp(1:end-2), ...
                                              filesep);
                imagesPath.imageType = temp(end-1);
                for t=[3 2 1]
                    if strfind(imagesPath.imageType{1},imageTypes{t})
                        imagesPath.imageType = imageTypes{t};
                        break;
                    end
                end
            end
        end
        if addPat == 1
            filesToProc(end+1).name = [folder patient.name];
            filesToProc(end).imagesPath = imagesPath;
        end
        clear b regexTerm ind addPat;
    end
    filesToProc = filesToProc(2:end);
end
end
%% turn the files into something easy to work with
if 1==0
for patItr = 1:length(filesToProc)
    patMat = struct('exists',[],'images',[],'ROI',[],'info',struct('TR',[],'flipAngle',[],'TE',[]),'ex',[]);
    for imageTypeItr = 1:4
        if ~isempty(filesToProc(patItr).imagesPath{imageTypeItr})
            iPath = filesToProc(patItr).imagesPath{imageTypeItr}.images;

            imageFiles = dir([iPath '*.dcm']);
            tempindex = [];
            for n=1:length(imageFiles)
                temp = dicominfo([iPath imageFiles(n).name]);
                if (temp.EchoTime > 0)
                    tempindex(end+1)=n;
                end
            end
            imageFiles = imageFiles(tempindex);
            clear tempindex temp;

            %imageFiles = imageFiles(3:end);
            temp = dicominfo([iPath imageFiles(1).name]);
            flipAngle = temp.FlipAngle;
            TR = temp.RepetitionTime;
            images = zeros(temp.Width,temp.Height,length(imageFiles));
            clear temp;
            TE = zeros(length(imageFiles),1);
            for n=1:length(imageFiles)
                temp = dicominfo([iPath imageFiles(n).name]);
                TE(n) = temp.EchoTime;
                images(:,:,n) = dicomread([iPath imageFiles(n).name]);
            end

            roiPath = dir([iPath filesep() 'ROI' filesep() 'liver-*.dcm.mat']);
            %ROI = load([iPath filesep() 'ROI' filesep() roiPath(1).name]);
            try 
                ROI = load(filesToProc(patItr).imagesPath{imageTypeItr}.roi);
            catch ex
                patMat.ex{imageTypeItr} = ex;
            end
            clear roiPath;
            patMat.images{imageTypeItr} = images;
            patMat.ROI{imageTypeItr} = ROI;
            patMat.info(imageTypeItr).TE = TE;
            patMat.info(imageTypeItr).TR = TR;
            patMat.info(imageTypeItr).flipAngle = flipAngle;
            patMat.exists{imageTypeItr} = 1;
        else
            patMat.exists{imageTypeItr} = 0;
        end
    end
    fileString = sprintf('../proc_mat/patient_%03i.mat',patItr);
    save(fileString,'patMat');
    patMatFiles{patItr} = sprintf('proc_mat/patient_%03i.mat',patItr)
    
end
%save('../proc_mat/patMatFiles.mat','patMatFiles');
end
%%
%Fit with and without PD estimator
%if ~exist('preguessT2s')
    %    load('../proc_mat/patMatFiles.mat','patMatFiles');
    %    load('results_t2sonly_round1.mat');
    %    for n=1:72;
        %        preguessT2(n) = mean(result.results(n).result(2).out.noPD.T2);
        %    end
    %    preguessT2s = preguessT2;
    %end
%
if 0==1
myvars.muscleT1 = 1008;
%chooseContrast = 2;  %this actually selects a scan type, it's a poorly chosen name
%myvars.contrastType = contrastTypes{chooseContrast};
if ~isvarname('result')
    result2 = struct;
else
    display('make sure you''re not overwriting data');
end

startVal = 1;
if exist('patItr')
    startVal = patItr;
end
hpcc = 0;
%for chooseImageTypeInd = 1:4
%    myvars.chooseImageTypeInd = chooseImageTypeInd;
    if hpcc == 1
        cluster = parcluster('hpcc_remote_r2014a');
        ClusterInfo.setWallTime('23:59:00');
        ClusterInfo.setQueueName('');
        appendRoot = '/home/rcf-40/eamondoy/jw3/eamondoy/Boston/';
        job = batch(cluster,'runParallelFittingScript','AttachedFiles',{'bostonFittingOneScan.m','parfor_progress.m','runParallelFitting.m','runParallelFittingScript.m','expc.m','correctT1.m','correctT1_SE.m','weightT1.m','weightT1_SE.m','NewFit2.m' ...
                            ,'recalcT1_1p5T.m'},'Pool',31);
        wait(job)
        result2 = load(job,'results');
        
    else
        appendRoot = '/Volumes/hellinabucket/Eamon/Powell_Patient_Data/';
        runParallelFittingScript;
    
    end
%end

save('workspace_3');






end