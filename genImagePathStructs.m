function out = genImagePathStructs(imRoot,subPathFile)

fid = fopen(subPathFile,'r');
paths = {};
while ~feof(fid)
    line = fgets(fid);
    line = line(1:end-1); %trim the newline
    paths{end+1} = line;
end
fclose(fid);

out = {};
lastVisit = '';
for n=1:length(paths) 
    fprintf('Running %02i\n',n);
    roiFiles = dir([imRoot paths{n} '/liver-*.dcm.mat']);
    roiPathCell = strsplit(paths{n},'/');
    patID = roiPathCell{1};
    if ~strcmp(lastVisit,[roiPathCell{1} '/' roiPathCell{2}])
        %new patient
        lastVisit = [roiPathCell{1} '/' roiPathCell{2}];
        outExam = struct('ute',[],'gre',[],'demo',[]);
    end
        
    imfolder = strjoin(roiPathCell(1:end-1),'/');
    patfolder = strjoin(roiPathCell(1:end-2),'/');
    
    imname = roiFiles(1).name;
    imname = imname(7:end-4);
    roiPath = [imRoot '/' paths{n} '/' roiFiles(1).name];
    if strfind(roiPath,'/UTE_')
        isUTE = 1;
        imPaths = buildUTEPaths([imRoot '/' patfolder],imname,roiFiles(1).name);
    else
        isUTE = 0;
        imPaths = buildGREPaths([imRoot '/' imfolder]);
    end
    outS = struct('im',imPaths,'roi',roiPath);
    if isUTE
        outExam.ute = outS;
    else
        outExam.gre = outS;
    end
    if (~isempty(outExam.ute) && ~isempty(outExam.gre))
       out{end+1} = outExam;
    end
end


end  %end of the title function


function utepaths = buildUTEPaths(patFolder,imname,roiname)
    imfolders = dir([patFolder '/UTE_*']);
    imnumber = roiname(15:end-8);
    utepaths = {};
    for n=1:length(imfolders)
        if ~strcmp(imfolders(n).name(end-1:end),'_0')
            imagename = dir([patFolder '/' imfolders(n).name '/IM-*-0001.dcm']);
            imagename.name(9:end-4) = imnumber;
            utepaths{end+1} = [patFolder '/' imfolders(n).name '/' imagename.name];
        end
    end
end

function grepaths = buildGREPaths(patFolder)
    ims = dir([patFolder '/IM-*-0001.dcm']);
    imnumber = ims(1).name(4:7);
    grepaths = {};
    nIms = 16;
    for n=1:nIms
        grepaths{end+1} = sprintf('%s/IM-%s-%04i.dcm',patFolder,imnumber,n);
    end
end


