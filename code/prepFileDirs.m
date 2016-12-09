function [out] = prepFileDirs(filesToProc)
    for f=filesToProc
        pRoot = [f.imagesPath.basePath filesep()]
        f2 = findIms(pRoot,f);
        if ~exist('out')
            out = f2;
        else
            out(end+1) = f2;
        end
    end
end

function [f] = findIms(pRoot,f)
        b = dir(pRoot);
        pS = regexpi({b.name},'SE_[0-9]+ms_BH_[1-9][0-9]+','match');
        
        pS = pS(find(~cellfun(@isempty,pS)));
        % dirty hack
        if strfind(pRoot,'3T_012CL/07_18_2014/3T/')
            pS = {};
            pS{1} = {'hahn'};
        end
        f.pS = trimEmptyDirs(pRoot,pS);
        
        f.roiS = findROI(pRoot,f.pS);
        f.pE = regexpi({b.name},'(((tse4545_dc_|4545_dc_)[0-9]+_[1-9][0-9]+)|(T2W_TSE_[0-9]+_ms_grad_[1-9][0-9]+))','match');   
        f.pE = f.pE(find(~cellfun(@isempty,f.pE)));
        f.roiE = findROI(pRoot,f.pE);
end

function [roiPath] = findROI(root,p)
    for p1=p
        path = p1{:}{:};
        tPath = [root '/' path '/ROI'];
        a = dir([tPath]);
        if size(a,1) > 0
            roiPath = [tPath '/' a(end).name];
        end
    end
end


function [pO] = trimEmptyDirs(root,pS)
    pO = cell(1);
    for t=pS
        a=dir([root '/' t{:}{:} '/*.dcm']);
        if size(a,1)>0
            pO(end+1) = t;
        end
    end
    pO = pO(2:end);
end
