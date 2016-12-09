inClause = [];
for n=1:20
    no(n) = regexpi(out{n}.name,'(3T_(?<value>[0-9]+)[A-Z]+|3T_(?<value>[0-9]+)','names')
    inClause = [inClause ',' no(n).value] 
end
inClause = [inClause(2:end) ')'];


queryString = strcat( 'SELECT Protocols.2014_00034_3T, MRI_Chest.R2_Liver,', ...
 'MRI_Chest.R2s_Liver, MRI_Chest.DOE ', ...
 ' FROM Protocols, MRI_Chest  ', ...
 ' WHERE Protocols.PID = MRI_Chest.PID', ...
 ' AND MRI_Chest.`Field Strength` LIKE "1.5%" ',  ...
 ' AND Protocols.2014_00034_3T IS NOT NULL ', ...
 ' AND Protocols.2014_00034_3T IN ( ',...
 inClause(2:end), ... 
 ' ORDER BY Protocols.2014_00034_3T;')



%% response

R2R2sLIC = [     37.9 ,      90.4 ;
   124.05 ,     417.9 ;
     56.1 ,       197 ;
    308.9 ,    1362.6 ;
      375 ,    1625.9 ;
     41.2 ,     148.4 ;
    186.6 ,     692.5 ;
    132.8 ,     370.7 ;
     18.6 ,      55.8 ;
    266.4 ,    1624.1 ;
       30 ,      99.9 ;
       10 ,        33 ;
       76 ,     259.5 ;
     18.9 ,      49.1 ;
      352 ,      1600 ;
    180.4 ,     425.3 ;
    187.6 ,     495.2 ;
    175.5 ,       689 ;
       47 ,     153.8 ;
   189.7 ,     743.7 ;];


names = {'012', '014', '016', '020', '023', '024', '025', '026', '027', '028', '029', '030', '031', '032', '033', '038', '038', '039', '040', '042'};

%%
for n=1:20
    dbLIC(n) = getLIC(R2R2sLIC(n,2),'R2*','1.5T');
    out{n}.dbLIC = dbLIC(n);
end

%%
tInd = find( R2out(:,3)> 0 & R2out(:,3) < 140);%700 ) ; %& pLIC'>0);
 

inClause2 = [];
for n=tInd'
    no(n) = regexpi(out{n}.name,'(3T_(?<value>[0-9]+)[A-Z]+|3T_(?<value>[0-9]+)','names')
    inClause2 = [inClause2 ',' no(n).value] 
end
inClause2 = [inClause2(2:end) ')'];


queryString = strcat( 'SELECT Patient_List.Gender, Patient_List.DOB ', ...
 ' FROM Patient_List, Protocols, MRI_Chest  ', ...
 ' WHERE Protocols.PID = MRI_Chest.PID', ...
 ' AND Protocols.PID = Patient_List.Patient_ID', ...
 ' AND MRI_Chest.`Field Strength` LIKE "3%" ',  ...
 ' AND Protocols.2014_00034_3T IN ( ',...
 inClause2(2:end), ... 
 ' ORDER BY Protocols.2014_00034_3T;')

% SELECT DOB, Gender, 
% in
% (C0852537,C1264073,C1476629,C1255856,C1465480,C1466267,C1326353,C4021845,C1100101,C4008793,C1575361,C1672163,C1526154,C1667366,C1889615)
%{

SELECT Protocols.2014_00034_3T, Patient_List.Gender, Patient_List.DOB
FROM Protocols, Patient_List
WHERE Protocols.2014_00034_3T IN (012,014,016,024,025,026,027,028,029,030,031,032,039,040) 
AND Protocols.PID = Patient_List.Patient_ID
ORDER BY 2014_00034_3T

%}




