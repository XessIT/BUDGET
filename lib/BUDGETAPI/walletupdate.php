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
    $incomeId = $data['incomeId'];
    $remainingAmount = $data['remainingAmount'];
    $todate = $data['todate'];

    // Get the current date in the same format as sent from Dart (YYYY-MM-DD)
    $currentDate = date('Y-m-d');

    // Check if todate is the current date
    if ($todate === $currentDate) {
        $conn = connectToDatabase();

        // Update the wallet amount
        $sqlUpdate = "UPDATE wallet
                      SET wallet = '$remainingAmount'
                      WHERE uid = '$uid' AND incomeId = '$incomeId'";

        if ($conn->query($sqlUpdate) === TRUE) {
            echo json_encode(array("message" => "Wallet amount updated successfully"));
        } else {
            echo json_encode(array("error" => "Error updating wallet amount: " . $conn->error));
        }

        $conn->close();
    } else {
        echo json_encode(array("error" => "Not the current date, skipping wallet update"));
    }
} else {
    echo json_encode(array("error" => "Invalid request method"));
}
?>
