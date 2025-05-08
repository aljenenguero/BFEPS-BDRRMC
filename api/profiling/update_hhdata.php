<?php
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate Household Data
    $requiredFields = ['household_id', 'household_street', 'household_zone', 'household_lot', 'material_used', 'toilet_facility', 'means_of_communication', 'source_of_water', 'electricity', 'household_with', 'family_income', 'residents'];
    foreach ($requiredFields as $field) {
        if (!isset($data[$field])) {
            echo json_encode(["success" => false, "message" => "Missing required field: $field"]);
            exit();
        }
    }

    $household_id = $data['household_id'];
    $residents = $data['residents'];
    // tighali ko si id
    // Validate Residents Data BEFORE updating household
    foreach ($residents as $resident) {
        $residentRequiredFields = ['first_name', 'last_name', 'civil_status', 'religion', 'birth_date', 'age', 'gender', 'education', 'occupation', 'beneficiary', 'pregnant', 'disability', 'household_type'];
        foreach ($residentRequiredFields as $rField) {
            if (!isset($resident[$rField])) {
                echo json_encode(["success" => false, "message" => "Missing resident field: $rField"]);
                exit();
            }
        }
    }

    // Now that validation is complete, begin transaction
    $conn->begin_transaction();
    try {
        // Update household
        $stmt = $conn->prepare("UPDATE households SET household_street = ?, household_zone = ?, household_lot = ?, material_used = ?, toilet_facility = ?, means_of_communication = ?, source_of_water = ?, electricity = ?, household_with = ?, family_income = ? WHERE id = ?");
        
        $stmt->bind_param("ssssssssssi", $data['household_street'], $data['household_zone'], $data['household_lot'], $data['material_used'], 
            $data['toilet_facility'], $data['means_of_communication'], $data['source_of_water'], $data['electricity'], 
            $data['household_with'], $data['family_income'], $household_id);
        $stmt->execute();

        // Update residents
        $stmt = $conn->prepare("UPDATE residents SET 
            profile_picture = ?, 
            first_name = ?, 
            middle_name = ?, 
            last_name = ?, 
            suffix = ?, 
            alias = ?, 
            contact_number = ?, 
            civil_status = ?, 
            religion = ?, 
            birth_date = ?, 
            age = ?, 
            gender = ?, 
            education = ?, 
            occupation = ?, 
            beneficiary = ?, 
            pregnant = ?, 
            disability = ?, 
            household_type = ? 
        WHERE id = ?"); 

        foreach ($residents as $resident) {
            $stmt->bind_param("ssssssssssisssssssi", 
                    $resident['profile_picture'], 
                    $resident['first_name'],
                    $resident['middle_name'], 
                    $resident['last_name'], 
                    $resident['suffix'], 
                    $resident['alias'], 
                    $resident['contact_number'], 
                    $resident['civil_status'], 
                    $resident['religion'], 
                    $resident['birth_date'],
                    $resident['age'], 
                    $resident['gender'], 
                    $resident['education'], 
                    $resident['occupation'], 
                    $resident['beneficiary'], 
                    $resident['pregnant'], 
                    $resident['disability'], 
                    $resident['household_type'], 
                    $resident['id']); 
                
            if (!$stmt->execute()) {
                echo json_encode(["success" => false, "message" => "Error updating resident: " . $stmt->error]);
                    exit();
                }
        }

        $conn->commit();
        echo json_encode(["success" => true, "message" => "Data updated successfully"]);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
