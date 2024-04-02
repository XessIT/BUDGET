<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection function
function connectToDatabase() {
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "budget";

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}

// Create Record (INSERT operation)

function createRecord($data){
    $conn = connectToDatabase();
    $uid = $data['uid'];
    $wallet = $data['wallet'];

    // Check if a record with the given UID already exists
    $check_sql = "SELECT * FROM wallet WHERE uid = '$uid'";
    $check_result = $conn->query($check_sql);

    if ($check_result->num_rows > 0) {
        // If record exists, update the wallet amount by adding the new amount to the existing one
        $existing_row = $check_result->fetch_assoc();
        $existing_wallet = $existing_row['wallet'];
        $updated_wallet = $existing_wallet + $wallet;

        // Update the wallet amount
        $update_sql = "UPDATE wallet SET wallet = '$updated_wallet' WHERE uid = '$uid'";
        if ($conn->query($update_sql) === TRUE) {
            echo json_encode(array("message" => "Wallet amount updated successfully"));
        } else {
            echo json_encode(array("error" => "Error updating wallet amount: " . $conn->error));
        }
    } else {
        // If record doesn't exist, insert a new record
        $insert_sql = "INSERT INTO wallet (uid, wallet) VALUES ('$uid', '$wallet')";
        if ($conn->query($insert_sql) === TRUE) {
            echo json_encode(array("message" => "New record created successfully"));
        } else {
            echo json_encode(array("error" => "Error: " . $insert_sql . "<br>" . $conn->error));
        }
    }

    $conn->close();
}




function readRecords($uid) {
    $conn = connectToDatabase();
    $sql = "SELECT wallet FROM wallet WHERE uid = '$uid'";
    $result = $conn->query($sql);

    $records = array();

    if ($result->num_rows > 0) {
        // Output data of each row
        while ($row = $result->fetch_assoc()) {
            $records[] = $row;
        }
        echo json_encode($records);
    } else {
        echo json_encode(array("message" => "0 results"));
    }

    $conn->close();
}


function updateWallet($uid, $amountNeeded) {
    $conn = connectToDatabase();
    // Get the current wallet amount for the specified user ID
    $sqlSelect = "SELECT wallet FROM wallet WHERE uid='$uid'";
    $result = $conn->query($sqlSelect);
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $currentAmount = $row['wallet'];
        // Deduct the needed amount from the current wallet amount
        $newAmount = $currentAmount - $amountNeeded;
         if ($newAmount < 0) {
                    echo "Insufficient balance in the wallet";
                    return;
                }

        // Update the wallet amount in the database
        $sqlUpdate = "UPDATE wallet SET wallet='$newAmount' WHERE uid='$uid'";
        if ($conn->query($sqlUpdate) === TRUE) {
            echo "Wallet amount updated successfully";
        } else {
            echo "Error updating wallet amount: " . $conn->error;
        }
    } else {
        echo "User not found or wallet data missing";
    }
    $conn->close();
}


// Handle incoming HTTP requests
// Handle incoming HTTP requests
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);

    createRecord($data);
} elseif ($_SERVER["REQUEST_METHOD"] === "GET") {
    if (isset($_GET['uid'])) {
        $uid = $_GET['uid'];
        readRecords($uid);
    } else {
        echo json_encode(array("error" => "uid parameter is missing"));
    }
} elseif ($_SERVER["REQUEST_METHOD"] === "PUT") {
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);
    // Check if the request includes an action to update the wallet
    if (isset($data['action']) && $data['action'] === 'update_wallet') {
        $uid = $data['uid'];
        $amountNeeded = $data['amount_needed'];
        updateWallet($uid, $amountNeeded);
    } else {
        // Proceed with other PUT operations if needed
    }
}


?>
