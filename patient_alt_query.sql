SELECT
        Patient_List.Acrostic,
        ABS(TIMESTAMPDIFF(DAY,3tl.DOE,STR_TO_DATE(%s,'%%Y%%m%%d'))) TimeBetweenScans,
        3tl.ALT,
        3tl.Ferritin
FROM
        Patient_List,
        Protocols,
        `3T Labs` 3tl
WHERE
        Patient_List.Patient_ID = Protocols.PID
        AND 3tl.PatientID = Protocols.PID
        AND Protocols.2014_00034_3T = %s

ORDER BY
      TimeBetweenScans ASC

 LIMIT 1
;
