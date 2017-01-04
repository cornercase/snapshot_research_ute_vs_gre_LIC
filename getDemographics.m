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
erRes.DOB = {'0000-00-00 00:00:00'};
erRes.Gender =  {''};
erRes.ClinicalStatus =  {''};
erRes.R2_Liver_1p5T =  -1;
erRes.R2s_Liver_1p5T =  -1;
erRes.DOE =  {''};
erRes.Age_At_Scan =  -1;
erRes.FieldStrength =  {'0.0 T'};
erRes.TimeBetweenScans = -1;
erRes.scandatenearness =  -1;

fileID = fopen('patient_demographics_query.sql');
query_text = textscan(fileID,'%s', 'CollectOutput',1);
query_text = reshape(query_text{1},1,size(query_text{1},1));
query_text = strjoin(query_text);
fclose(fileID);
for n=1:length(exams)
    clear qstring demoS tempP;
    runThis = 1;
    if runThis

        resFile = matfile(exams{n}.savePath);
        qstring = sprintf(query_text,resFile.examdate,exams{n}.patID);
        
        db.prepareStatement(qstring);% WHERE id = "{Si}"', 10001);
        try 
            result = db.query();
            err = '';
            resFile.Properties.Writable = true;
            resFile.demographics = result;
        catch err
            result = erRes;
            fprintf('Failed on index %i patID %s\n',n,exams{n}.patID);
        end
                
        errors = err;

    end
    
    
end

if saveBool ==1
    save('patientListBMIDemos','demoStructs');
end
