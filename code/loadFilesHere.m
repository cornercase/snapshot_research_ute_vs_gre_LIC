function [im, te, roi, info] = loadFilesHere(root, imF, roiPath, varargin);
    p = inputParser;
    p.addParameter('slice',-1);
    p.parse(varargin{:});
    
    

    % Easy stuff out of the way
    roi = load(roiPath);
    roi.liver = roi.roi.liver
    roi.muscle = roi.roi.muscle
    roi = rmfield(roi,'roi')
    
    %Now some confusing shit
    %Get the slice number of the ROI
    sROI = strsplit(roiPath,filesep())
    sROI = sROI(end);
    sROI = sROI{:}
    if ~regexpi(sROI,'IM-[0-9]+-[0-9]-.dcm.mat')
        error('something is amiss with your ROIs');
    end
    sROI = strsplit(sROI,'.');
    sROI = strsplit(sROI{1},'-');
    if p.Results.slice > 0
        slice = sprintf('%04i',p.Results.slice);
    else
        slice = sROI{end};
    end
    
    [im, te, info] = loadAndSort(root,imF,slice);

end


function [imstack, te, info] = loadAndSort(root,imF,slice)
    te = []
    imstack = [];
    for n=1:max(size(imF))
        tPath = [root '/' imF{n}{:} '/'];
        b = dir([tPath '*.dcm']);
        regexString = strcat(['IM-[0-9]+-' slice '.dcm']);
        imP = regexpi({b.name},regexString,'match');
        imP = imP(find(~cellfun(@isempty,imP)));
        for imT=imP
            iPath = [tPath filesep() imT{end}{:}];
            tempIm = dicomread(iPath);
            tempInfo = dicominfo(iPath);
            if isempty(imstack)
                info(1).TR = tempInfo.RepetitionTime/1000;
                info(1).flipangle = tempInfo.FlipAngle;
                te(1) = tempInfo.EchoTime;
                imstack(:,:,1) = tempIm;
            else
                info(end+1).TR = tempInfo.RepetitionTime;
                info(end+1).flipangle = tempInfo.FlipAngle;
                te(end+1) = tempInfo.EchoTime;
                imstack(:,:,end+1) = tempIm;
            end
        end
    end
    [te ix] = sort(te);
    imstack=imstack(:,:,ix);
    if te(1)>1
        te = te./1000;
    end
end
    
    