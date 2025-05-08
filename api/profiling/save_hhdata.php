<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate Household Data and log incoming data
    error_log(print_r($data, true)); // Log incoming data for debugging

    $requiredFields = ['household_street', 'household_zone', 'household_lot', 'material_used', 'toilet_facility', 'means_of_communication', 'source_of_water', 'electricity', 'household_with', 'family_income', 'residents'];
    foreach ($requiredFields as $field) {
        if (empty($data[$field])) { // Check if the field is empty
            echo json_encode(["success" => false, "message" => "Missing required field: $field"]);
            exit();
        }
    }

    $residents = $data['residents'];
    
    // Validate Residents Data BEFORE inserting household and log resident data
    error_log(print_r($residents, true)); // Log residents data for debugging

    foreach ($residents as $resident) {
        $residentRequiredFields = ['first_name', 'last_name', 'civil_status', 'religion', 'birth_date', 'age', 'gender', 'education', 'occupation', 'beneficiary', 'pregnant', 'disability', 'household_type'];
        foreach ($residentRequiredFields as $rField) {
            if (empty($resident[$rField])) { // Check if the resident field is empty
                echo json_encode(["success" => false, "message" => "Missing resident field: $rField"]);
                exit();
            }
        }
    }

    // Now that validation is complete, begin transaction
    $conn->begin_transaction();
    try {
        // Insert household
        $stmt = $conn->prepare("INSERT INTO households (household_street, household_zone, household_lot, material_used, toilet_facility, means_of_communication, source_of_water, electricity, household_with, family_income) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        $stmt->bind_param("ssssssssss", 
            $data['household_street'], 
            $data['household_zone'], 
            $data['household_lot'], 
            $data['material_used'], 
            $data['toilet_facility'], 
            $data['means_of_communication'], 
            $data['source_of_water'], 
            $data['electricity'], 
            $data['household_with'], 
            $data['family_income']
        );
        
        if (!$stmt->execute()) {
            error_log("SQL Error on household insert: " . $stmt->error);
            throw new Exception("Database error: " . $stmt->error);
        }
        
        $household_id = $stmt->insert_id;

        // Insert residents
        $stmt = $conn->prepare("INSERT INTO residents (household_id, profile_picture, first_name, middle_name, last_name, suffix, alias, contact_number, civil_status, religion, birth_date, age, gender, education, occupation, beneficiary, pregnant, disability, household_type) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        foreach ($residents as $resident) {
            // Prepare the values to bind
            $profilePicture = $resident['profile_picture'] ?? ''; 
            $first_name = $resident['first_name'];
            $middle_name = $resident['middle_name'] ?? ''; 
            $last_name = $resident['last_name'];
            $suffix = $resident['suffix'] ?? ''; 
            $alias = $resident['alias'] ?? ''; 
            $contact_number = $resident['contact_number'];
            $civil_status = $resident['civil_status'];
            $religion = $resident['religion'];
            $birth_date = $resident['birth_date'];
            $age = (int)$resident['age']; 
            $gender = $resident['gender'];
            $education = $resident['education'];
            $occupation = $resident['occupation'];
            $beneficiary = $resident['beneficiary'];
            $pregnant = $resident['pregnant'];
            $disability = $resident['disability'];
            $household_type = $resident['household_type'];
            
            // Bind parameters and execute
            $stmt->bind_param("issssssssssisssssss", 
                $household_id, 
                $profilePicture, 
                $first_name,
                $middle_name, 
                $last_name, 
                $suffix, 
                $alias, 
                $contact_number, 
                $civil_status, 
                $religion, 
                $birth_date,
                $age, 
                $gender, 
                $education, 
                $occupation, 
                $beneficiary, 
                $pregnant, 
                $disability, 
                $household_type
            );        
            if (!$stmt->execute()) {
                error_log("SQL Error on resident insert: " . $stmt->error);
                throw new Exception("Database error: " . $stmt->error);
            }
        }

        $conn->commit();
        echo json_encode(["success" => true, "message" => "Data saved successfully"]);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
