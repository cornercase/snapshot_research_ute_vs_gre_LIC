addpath(fullfile('/Users/eamon/repos/research_code/Useful Utilities/queryMySQL/', 'src'));
javaaddpath('/Users/eamon/mysql-connector-java-5.1.34-bin.jar');

%% import classes
import edu.stanford.covert.db.*;

saveBool = 0;

db = MySQLDatabase('woodrc1', 'wood_db', 'wooddb_read_only', 'WoodIronDB');

newpath = [pwd '/code/wood'];
if ~strfind(matlabpath(),newpath)
    init_path = matlabpath();
    newpath = [pwd '/code/wood'];
    matlabpath([newpath ':' init_path]);
end

%generate paths
exams = genImagePathStructs('./files/','file_subpaths.txt');

erRes.Acrostic =  {'err'};
erRes.TimeBetweenScans = -1;
erRes.Height = -1;
erRes.Weight = -1;
erRes.BSA = -1;
erRes.BMI = -1;
erRes.Ferritin = -1;
erRes.ALT = -1;

labsDict = {'Height','Weight','BSA'};

fileID = fopen('patient_labs_query.sql');
query_text = textscan(fileID,'%s', 'CollectOutput',1);
query_text = reshape(query_text{1},1,size(query_text{1},1));
query_text = strjoin(query_text);
bigtable_query_text = query_text;
fclose(fileID);
fileID = fopen('patient_alt_query.sql');
query_text = textscan(fileID,'%s', 'CollectOutput',1);
query_text = reshape(query_text{1},1,size(query_text{1},1));
query_text = strjoin(query_text);
alt_query_text = query_text;
fclose(fileID);
fprintf('%s,%s,%s,%s,%s,%s,%s,%s\n','ID','Acrostic','Height','Weight','BMI','BSA','Ferritin','ALT')
for n=1:length(exams)
    clear qstring demoS tempP;
    
    ores = erRes;
       
        
    resFile = matfile(exams{n}.savePath);
    qstring = sprintf(bigtable_query_text,resFile.examdate,exams{n}.patID);
        
    db.prepareStatement(qstring);% WHERE id = "{Si}"', 10001);
    try 
        result = db.query();
        err = '';
            
    catch err
        result = erRes;
        fprintf('Failed on index %i patID %s\n',n,exams{n}.patID);
    end


    try 
        ores.Acrostic = result.Acrostic{1};
        ores.Height = result.Height;
        ores.Weight = result.Weight;
    catch errTry
        fprintf('failed on n = %i',n);
            
    end
        
   
    errors = err;
        
    
    ores.BMI = ores.Weight/((ores.Height/100)^2);
    ores.BSA = sqrt( (ores.Height * ores.Weight )/ 3600 );
    qstring = sprintf(alt_query_text,resFile.examdate,exams{n}.patID);
        
    db.prepareStatement(qstring);% WHERE id = "{Si}"', 10001);
    try 
        result = db.query();
        ores.ALT = result.ALT;
        ores.Ferritin = result.Ferritin;
        err = '';
            
    catch err
        result = erRes;
        fprintf('Failed ALT index %i patID %s\n',n,exams{n}.patID);
    end
    
    fprintf('%s,%s,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f\n',exams{n}.patID,ores.Acrostic,ores.Height,ores.Weight,ores.BMI,ores.BSA,ores.Ferritin,ores.ALT)
    %resFile.Properties.Writable = true;
    %resFile.demographics = result;
    
end

if saveBool ==1
    save('patientListBMIDemos','demoStructs');
end
