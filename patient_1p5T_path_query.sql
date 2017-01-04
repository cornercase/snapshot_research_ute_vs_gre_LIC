SELECT
        p.ClinicalStatus,
        p.LastName,
        p.FirstName,
        DATE_FORMAT(MRI_Chest.DOE,'%Y_%m_%d') low_scan_date,
        ABS(TIMESTAMPDIFF(DAY,MRI_Chest.DOE,STR_TO_DATE('2016_12_31','%Y_%m_%d'))) TimeBetweenScans


FROM
        Patient_List p,
        Protocols,
        MRI_Chest

WHERE
        p.Patient_ID = Protocols.PID
        AND MRI_Chest.PID = p.Patient_ID
        AND MRI_Chest.FieldStrength = '1.5 T'
        AND Protocols.2014_00034_3T = '057'        

ORDER BY
      TimeBetweenScans ASC

#LIMIT
#        1
;
