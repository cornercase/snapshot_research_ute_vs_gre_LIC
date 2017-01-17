SELECT
        Patient_List.Acrostic,
        Patient_List.Patient_ID,
        ABS(TIMESTAMPDIFF(DAY,MRI_Chest.DOE,STR_TO_DATE(%s,'%%Y%%m%%d'))) TimeBetweenScans,
        MRI_Chest.DOE,
        MRI_Chest.Height,
        MRI_Chest.Weight

FROM
        Patient_List,
        Protocols,
        MRI_Chest

WHERE
        Patient_List.Patient_ID = Protocols.PID
        AND MRI_Chest.PID = Protocols.PID
        AND Protocols.2014_00034_3T = %s
        AND MRI_Chest.Height IS NOT NULL

ORDER BY
      TimeBetweenScans ASC

Limit 1
;
