exams = genImagePathStructs('./files/','file_subpaths.txt');

genderMale = 0;
genderFemale = 0;
ageArray = 0;
%weightArray = ones(length(exams),1);
lastAcrostic = 'NOPE';
countThal = 0;
countSickle = 0;
countOther = 0;
lic = 0;
for n=1:length(exams)
    
    resFile = matfile(exams{n}.savePath);
    demos = resFile.demographics;
    ageArray(n) = demos.Age_At_Scan;
    if strcmp(lastAcrostic,demos.Acrostic)
        ageArray(n-1) = (ageArray(n-1)+demos.Age_At_Scan)/2;
        ageArray(n) = NaN;
    end
    
    if ~isnan(ageArray(n))

        if strcmp(demos.ClinicalStatus{1},'Thalassemia Major')
            countThal = countThal + 1;
        else if strfind(demos.ClinicalStatus{1},'Sickle')
                countSickle = countSickle + 1;
            else
                countOther = countOther +1;
            end
        end
        if ~strcmp(lastAcrostic,demos.Acrostic)
            if strcmp(demos.Gender,'F')
                genderFemale = genderFemale + 1;
            else
                genderMale = genderMale + 1;
            end
        end
    end
    lastAcrostic = demos.Acrostic;
    lic(n) = getLIC(demos.R2s_Liver_1p5T,'R2*','1.5T','expc');
end
ageArray = ageArray(~isnan(ageArray));
fprintf('Gender Male: %i    Female: %i\n',genderMale,genderFemale);
fprintf('Age Mean: %0.2f    Std: %0.2f\n',mean(ageArray),std(ageArray));
fprintf('Thal Maj: %i     Sickle: %i    Other: %i\n', countThal, countSickle, countOther);