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

fileID = fopen('patient_1p5T_path_query.sql');
query_text = textscan(fileID,'%s', 'CollectOutput',1);

query_text = reshape(query_text{1},1,size(query_text{1},1));
query_text = strjoin(query_text);
fclose(fileID);
outID = fopen('~/Desktop/files.txt');
for n=1:length(exams)
    clear qstring demoS tempP;
    runThis = 1;
    if runThis

        resFile = matfile(exams{n}.savePath);
        qstring = sprintf(query_text,resFile.examdate,exams{n}.patID);
        
        db.prepareStatement(qstring);% WHERE id = "{Si}"', 10001);
        outFolder = [exams{n}.savePath(1:end-11) '1.5TGRE/'];
        result = db.query();
        if 0==1
        try 
            result = db.query();
            err = '';
            %resFile.Properties.Writable = true;
            %resFile.demographics = result;
            
            
            diseaseSubpath = [];
            switch result.ClinicalStatus{1}
                case 'Thalassemia Intermedia'
                    diseaseSubpath = 'Thal Intermedia';
                case 'Thalassemia Major'
                    diseaseSubpath = result.ClinicalStatus{1};
                case 'Sickle Cell Disease'
                	diseaseSubpath = result.ClinicalStatus{1};
                otherwise
                    diseaseSubpath = 'Other';
            end
            inBase = '/Volumes/data/Iron_Patients/';
            inPath = [inBase diseaseSubpath '/' sprintf('%s, %s/%s',result.LastName{1},result.FirstName{1},result.low_scan_date{1})];
            inPath = strrep(inPath,' ','\ ');
%            inPath = strrep(inPath,'Manae','Manea');
            cmmd=['find ' inPath ' -type d -name ''*Liver_R2_3_*'''];
            [status,rslt]=system(cmmd)
            if status == 0 || status == 130
                rscmd = ['rsync -a ' inPath ' ' outFolder];
                fprintf('%s\n',rscmd);
            else
                fprintf('check \n\n%s %s\n\n',inPath, outFolder);
            
            end
            
            
            
        catch err
            
            result = erRes;
            fprintf('Failed on index %i patID %s\n',n,exams{n}.patID);
            fprintf('%s %s\n',inPath,outFolder);
        end
                
        errors = err;
        end

    end
    
    
end
fclose(outID);
if saveBool ==1
    save('patientListBMIDemos','demoStructs');
end


