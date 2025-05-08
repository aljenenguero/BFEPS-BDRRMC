<?php
include 'db_connect.php';

$sql = "
    SELECT 
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
        households.created_at AS household_created_at, 
        households.updated_at AS household_updated_at, 
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
        
        -- Count of household members
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id) AS HouseholdMembersCount,
        -- Count of underaged individuals
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.age < 18) AS UnderagedCount,
        -- Count of seniors
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.age >= 60) AS SeniorCount,
        -- Count of pregnant individuals
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.pregnant = 'Yes') AS PregnantCount,
        -- Count of PWDs
        (SELECT COUNT(*) FROM residents r WHERE r.household_id = households.id AND r.disability IN ('Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'Others')) AS PWDCount,
        
        -- Total counts
        (SELECT COUNT(*) FROM residents) AS TotalPopulation,
        (SELECT COUNT(DISTINCT households.id) FROM households) AS TotalFamilies,
        (SELECT COUNT(*) FROM residents WHERE gender = 'Female') AS TotalFemales,
        (SELECT COUNT(*) FROM residents WHERE gender = 'Male') AS TotalMales,
        (SELECT COUNT(*) FROM residents WHERE gender IN ('LGBT', 'Non-binary', 'Transman', 'Transwoman')) AS TotalLGBTQIA,
        (SELECT COUNT(*) FROM residents WHERE age < 18) AS TotalUnderaged,
        (SELECT COUNT(*) FROM residents WHERE age >= 60) AS TotalSeniors,
        (SELECT COUNT(*) FROM residents WHERE disability IN ('Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'Others')) AS TotalPWDs
        
    FROM households 
    LEFT JOIN residents ON households.id = residents.household_id
";

$result = $conn->query($sql);

$records = []; 

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $household_id = $row['household_id'];
        
        // If the household doesn't exist in the records array, create it
        if (!isset($records[$household_id])) {
            $records[$household_id] = [
                'household_id' => $household_id,
                'household_street' => $row['household_street'],
                'household_zone' => $row['household_zone'],
                'household_lot' => $row['household_lot'],
                'material_used' => $row['material_used'],
                'toilet_facility' => $row['toilet_facility'],
                'means_of_communication' => $row['means_of_communication'],
                'source_of_water' => $row['source_of_water'],
                'electricity' => $row['electricity'],
                'household_with' => $row['household_with'],
                'family_income' => $row['family_income'],
                'HouseholdMembersCount' => $row['HouseholdMembersCount'],
                'UnderagedCount' => $row['UnderagedCount'],
                'SeniorCount' => $row['SeniorCount'],
                'PregnantCount' => $row['PregnantCount'],
                'PWDCount' => $row['PWDCount'],
                'TotalPopulation' => $row['TotalPopulation'],
                'TotalFamilies' => $row['TotalFamilies'],
                'TotalFemales' => $row['TotalFemales'],
                'TotalMales' => $row['TotalMales'],
                'TotalLGBTQIA' => $row['TotalLGBTQIA'],
                'TotalUnderaged' => $row['TotalUnderaged'],
                'TotalSeniors' => $row['TotalSeniors'],
                'TotalPWDs' => $row['TotalPWDs'],
                'household_created_at' => $row['household_created_at'], 
                'household_updated_at' => $row['household_updated_at'],
                'residents' => [] // Initialize residents array
            ];
        }
        
        // Add resident data to the household
        if ($row['resident_id'] !== null) {
            $records[$household_id]['residents'][] = [
                'resident_id' => $row['resident_id'], // Include resident_id
                'profile_picture' => $row['profile_picture'],
                'first_name' => $row['first_name'],
                'middle_name' => $row['middle_name'],
                'last_name' => $row['last_name'],
                'suffix' => $row['suffix'],
                'alias' => $row['alias'],
                'contact_number' => $row['contact_number'],
                'civil_status' => $row['civil_status'],
                'religion' => $row['religion'],
                'birth_date' => $row['birth_date'],
                'age' => $row['age'],
                'gender' => $row['gender'],
                'education' => $row['education'],
                'occupation' => $row['occupation'],
                'beneficiary' => $row['beneficiary'],
                'pregnant' => $row['pregnant'],
                'disability' => $row['disability'],
                'household_type' => $row['household_type'],
            ];
        }
    }
}

// Re-index the records array to be a simple array
$records = array_values($records);

echo json_encode($records);

$conn->close();

