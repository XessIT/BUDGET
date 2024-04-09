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

// Read Records (SELECT operation)
function readRecords($uid) {
    $conn = connectToDatabase();

    $sql = "SELECT BORROW_AMT, LENDING_AMT, REVERSE, LOG_DATE FROM wallet_log WHERE USER_ID = '$uid'";
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

// Handle incoming HTTP requests
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    if (isset($_GET['uid'])) {
        $uid = $_GET['uid'];
        readRecords($uid);
    } else {
        echo json_encode(array("error" => "IncomeId parameter is missing"));
    }
}  else {
    echo json_encode(array("error" => "Invalid request method"));
}
?>
