
 <?php
include 'db_connect.php';

$sql = "
    SELECT 
        residents.id AS resident_id,
        residents.profile_picture,
        residents.first_name,
        residents.middle_name,
        residents.last_name,
        residents.suffix,
        residents.alias,
        residents.contact_number,
        residents.civil_status,
        residents.religion,
        residents.birth_date,
        residents.age,
        residents.gender,
        residents.education,
        residents.occupation,
        residents.beneficiary,
        residents.pregnant,
        residents.disability,
        residents.household_type,
        
        households.id AS household_id,
        households.household_street, 
        households.household_zone, 
        households.household_lot,
        households.material_used,
        households.toilet_facility,
        households.means_of_communication,
        households.source_of_water,   
        households.electricity,
        households.household_with,
        households.family_income,

        CASE WHEN residents.disability IN ('Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'Others') THEN 1 ELSE 0 END AS pwdcheck,
        CASE WHEN residents.age < 18 THEN 1 ELSE 0 END AS underagedcheck,
        CASE WHEN residents.age >= 60 THEN 1 ELSE 0 END AS seniorcheck,
        CASE WHEN residents.pregnant IN ('Yes') THEN 1 ELSE 0 END AS pregnantcheck

        
    FROM residents
    JOIN households ON households.id = residents.household_id
    ORDER BY residents.last_name, residents.first_name
";

$result = $conn->query($sql);

$records = []; 

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $records[] = $row;
    }
}   

echo json_encode($records);

$conn->close();
