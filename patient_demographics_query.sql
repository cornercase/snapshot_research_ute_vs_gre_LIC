SELECT
        Patient_List.Acrostic,
        Patient_List.DOB,
        Patient_List.Gender,
        Patient_List.ClinicalStatus,
        MRI_Chest.R2_Liver R2_Liver_1p5T,
        MRI_Chest.R2s_Liver R2s_Liver_1p5T,
        MRI_Chest.DOE,
        ABS(TIMESTAMPDIFF(DAY,MRI_Chest.DOE,STR_TO_DATE(%s,'%%Y%%m%%d'))) TimeBetweenScans,
        TIMESTAMPDIFF(DAY,Patient_List.DOB,MRI_Chest.DOE)/365 Age_At_Scan

FROM
        Patient_List,
        Protocols,
        MRI_Chest

WHERE
        Patient_List.Patient_ID = Protocols.PID
        AND MRI_Chest.PID = Patient_List.Patient_ID
        AND MRI_Chest.FieldStrength = '1.5 T'
        AND Protocols.2014_00034_3T = %s

ORDER BY
      TimeBetweenScans

LIMIT
        1
