function out=GetHeaderInfo(hdr)
Dcm_Date_of_Exam = hdr.StudyDate; % Convert to Proper Format


yy = Dcm_Date_of_Exam(1:4) ; % extract year
mm = Dcm_Date_of_Exam(5:6) ; % extract month
dd = Dcm_Date_of_Exam(7:end) ; % extract day

Date_of_Exam = sprintf('%s/%s/%s',mm,dd,yy) ;

Patient_ID= hdr.PatientID;
 
%BIRTHDATE
BirthDate = hdr.PatientBirthDate;
if length(BirthDate) > 7
        yy = BirthDate(1:4) ; % extract year
        mm = BirthDate(5:6) ; % extract month
        dd = BirthDate(7:end); % extract day
        DOB = sprintf('%s/%s/%s',mm,dd,yy) ; 
else
    DOB = ''
end
        Gender = hdr.PatientSex;

%NAME CONVERSION

PatientNameFromHeader=hdr.PatientName;
PatientName=hdr.PatientName;
test = struct2cell(PatientName);
if max(size(test)>1)
    Last_Name = PatientNameFromHeader.FamilyName;
    First_Name = PatientNameFromHeader.GivenName;
    disp('First PatientName format worked.'); 
else
    PatientName = (test(1,1));
    PatientName = char(PatientName) ;
    comma = find(PatientName == ',');
    if comma>0
            
        Last_Name= PatientName(1:comma-1);    %Extract Last Name
        a=Last_Name(1);                       %Change from all upper case
        b=lower(Last_Name(2:end));
        Last_Name = strcat(a, b);

        First_Name=(PatientName(comma+ 1:end));
        a=First_Name(1);                       %Change from all upper case
        b=lower(First_Name(2:end));
        First_Name = strcat(a, b);
    else
        Last_Name=PatientName;
        First_Name='';
    end
end
out={Last_Name,First_Name,Patient_ID, Date_of_Exam, DOB,Gender,hdr.SeriesNumber};