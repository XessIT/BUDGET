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

// Handle incoming HTTP requests
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Receive JSON data from the request body
    $data = json_decode(file_get_contents('php://input'), true);

    // Extract data from JSON
    $uid = $data['uid'];
    $todate = $data['todate'];
    $remainingAmount = $data['remainingAmount'];

    // Get the current date in the same format as sent from Dart (YYYY-MM-DD)
    $currentDate = date('Y-m-d');

    // Check if todate is the current date
    if ($todate === $currentDate) {
        $conn = connectToDatabase();

        // Check if data already exists for the current date
        $sqlCheck = "SELECT * FROM wallet WHERE uid = '$uid'";
        $result = $conn->query($sqlCheck);

        if ($result->num_rows == 0) {
            // Insert new data into the wallet table
            $sqlInsert = "INSERT INTO wallet (uid, wallet, todate)
                          VALUES ('$uid', '$remainingAmount', '$todate')";

            if ($conn->query($sqlInsert) === TRUE) {
                echo json_encode(array("message" => "Wallet amount inserted successfully"));
            } else {
                echo json_encode(array("error" => "Error inserting wallet amount: " . $conn->error));
            }
        } else {
            echo json_encode(array("error" => "Data already exists for the current date, skipping wallet insertion"));
        }

        $conn->close();
    } else {
        echo json_encode(array("error" => "Not the current date, skipping wallet insertion"));
    }
} else {
    echo json_encode(array("error" => "Invalid request method"));
}
?>
