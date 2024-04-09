<?php
header("Content-Type: application/json");

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(array("error" => "Only POST requests are allowed."));
    exit;
}

// Check if required parameters are provided
$required_params = array("uid", "incomeId", "lendingAmt", "todate");
foreach ($required_params as $param) {
    if (!isset($_POST[$param])) {
        http_response_code(400); // Bad Request
        echo json_encode(array("error" => "Missing parameter: $param"));
        exit;
    }
}

// Get POST parameters
$uid = $_POST["uid"];
$incomeId = $_POST["incomeId"];
$lendingAmt = $_POST["lendingAmt"];
$todate = $_POST["todate"];

// Insert data into the database (Replace with your database connection code)
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "budget";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("error" => "Database connection failed: " . $conn->connect_error));
    exit;
}

$sql = "INSERT INTO wallet_log (uid, incomeId, lendingAmt) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssss", $uid, $incomeId, $lendingAmt, $todate);

if ($stmt->execute()) {
    http_response_code(200); // OK
    echo json_encode(array("message" => "Data inserted successfully."));
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("error" => "Failed to insert data."));
}

$conn->close();
?>
