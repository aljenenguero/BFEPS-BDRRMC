<?php
include 'db_connect.php';

function getRandomElement($array) {
    if (!is_array($array)) {
        return $array; // Prevents errors if not an array
    }
    return $array[array_rand($array)];
}

$firstNames = ["John", "Jane", "Alice", "Robert", "Michael", "Emily", "Sophia", "David", "Daniel", "Chris"];
$middleNames = ["","","","","","",];
$lastNames = ["Doe", "Smith", "Brown", "Johnson", "Williams", "Martinez", "Garcia", "Rodriguez", "Lopez", "Anderson"];
$suffix = ["Jr","Sr","","","","",];
$zones = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5'];
$civilStatuses = ['Single', 'Married', 'Widowed', 'Separated', 'Divorced', 'Common Law/Live-in', 'Others'];
$religions = ['Roman Catholic', 'Born Again Christian', 'Iglesia ni Cristo', 'Muslim', 'Buddhist', 'Atheist', 'Others'];
$genders = ['Female', 'Male', 'Non-binary', 'Transman', 'Transwoman', 'Prefer not to say', 'Others'];
$educations = ['Elementary Level', 'Elementary Graduate', 'Highschool Level', 'Highschool Graduate', 'College Level', 'College Graduate', 'Post Graduate', 'Vocational', 'None', 'Others'];
$occupations = ['Business Owner', 'Driver', 'Farmer', 'Fisherfolk', "Gov't. Employee", 'Health Worker', 'Housekeeper', 'Housewife', 'Labourer', 'OFW', 'Private Employee', 'Retired', 'Security Personnel', 'Self Employed', 'Student', 'Teacher/Educator', 'Technician/Mechanic', 'Vendor', 'None', 'Others'];
$beneficiaries = ['Yes', 'No'];
$pregnantOptions = ['Yes', 'No'];
$disabilities = ['Visual Impairment', 'Hearing Impairment', 'Speech Impairment', 'Physical Disability', 'Intellectual Disability', 'Psychosocial Disability', 'Learning Disability', 'Multiple Disabilities', 'None', 'Others'];
$householdMemberTypes = ['Head of the Household', 'Spouse', 'Child', 'Parent', 'Sibling', 'Grandparent', 'Grandchild', 'Aunt/Uncle', 'Cousin', 'In-Law', 'Relative', 'House Helper', 'Boarder', 'Non-Relative', 'None', 'Others'];
$constructionMaterials = ['Strong Materials', 'Light Materials', 'Mixed Materials'];
$toiletFacilities = ['Level 1 - Unsanitary Toilet', 'Level 2 - Sanitary Toilet with Septic Tank', 'Level 3 - None'];
$communications = ['Telephone', 'Cellphone', 'Internet', 'None'];
$waterSources = ['Community Water System (Owned)', 'Community Water System (Shared)', 'Deep and Shallow Well (Owned)', 'Deep and Shallow Well (Shared)', 'Bottled Water/Purified/Distilled Water'];
$electricityOptions = ['Yes', 'No'];
$householdWithOptions = ['Vegetable Garden', 'Poultry', 'Livestock', 'Fishpond', 'None', 'Others'];
$family_incomes = ['₱5,000 (Below)', '₱6,000 - ₱10,000', '₱11,000 - ₱15,000', '₱16,000 - ₱20,000', '₱21,000 - ₱25,000', '₱26,000 - above'];

$numHouseholds = 10; // Number of dummy households
$numResidentsPerHousehold = rand(1, 10); // Random number of residents per household

for ($h = 1; $h <= $numHouseholds; $h++) {
    // Insert household first
    $household_street = "Street " . $h;
    $household_zone = "Zone " . rand(1, 5);
    $household_lot = rand(1, 100);
    $material_used = getRandomElement($constructionMaterials);
    $toilet_facility = getRandomElement($toiletFacilities);
    $communication = getRandomElement($communications);
    $waterSource = getRandomElement($waterSources);
    $electricity = getRandomElement($electricityOptions);
    $household_with = getRandomElement($householdWithOptions);
    $family_income = getRandomElement($family_incomes);

    // Fix: Use variables, not array names
    $householdSql = "INSERT INTO households (household_street, household_zone, household_lot, material_used, toilet_facility, means_of_communication, 
                     source_of_water, electricity, household_with, family_income) 
                     VALUES ('$household_street', '$household_zone', '$household_lot', '$material_used', '$toilet_facility', '$communication', 
                     '$waterSource', '$electricity', '$household_with', '$family_income')";
    
    if ($conn->query($householdSql) === TRUE) {
        $householdId = $conn->insert_id; // Get the inserted household ID

        // Ensure only **one** "Head of the Household" per household
        $isHeadAssigned = false;

        for ($r = 0; $r < $numResidentsPerHousehold; $r++) {
            $first_name = getRandomElement($firstNames);
            $last_name = getRandomElement($lastNames);
            $gender = getRandomElement($genders);
            $contact_number = "09" . rand(100000000, 999999999); // Generate random phone number
            $age = rand(1, 99);
            $dob = date("Y-m-d", strtotime("-$age years"));
            $civil_status = getRandomElement($civilStatuses);
            $religion = getRandomElement($religions);
            $education = getRandomElement($educations);
            $occupation = getRandomElement($occupations);
            $beneficiary = getRandomElement($beneficiaries);
            $pregnant = ($gender === "Female" && $age >= 18 && $age <= 45) ? getRandomElement($pregnantOptions) : "No";
            $disability = getRandomElement($disabilities);

            // Ensure only **one** "Head of the Household"
            if (!$isHeadAssigned) {
                $household_type = "Head of the Household";
                $isHeadAssigned = true;
            } else {
                $household_type = getRandomElement($householdMemberTypes);
            }

            
            $occupation = $conn->real_escape_string($occupation);

            $residentSql = "INSERT INTO residents (household_id, first_name, last_name, contact_number, gender, age, birth_date, civil_status, religion, 
                            education, occupation, beneficiary, pregnant, disability, household_type) 
                            VALUES ('$householdId', '$first_name', '$last_name', '$contact_number', '$gender', '$age', '$dob', '$civil_status', 
                            '$religion', '$education', '$occupation', '$beneficiary', '$pregnant', '$disability', '$household_type')";

            if ($conn->query($residentSql) === TRUE) {
                echo "Resident $r in Household $householdId inserted successfully <br>";
            } else {
                echo "Error inserting resident: " . $conn->error . "<br>";
            }
        }
    } else {
        echo "Error inserting household: " . $conn->error . "<br>";
    }
}

$conn->close();
?>
