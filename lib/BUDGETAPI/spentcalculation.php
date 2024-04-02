

<?php
error_log($_SERVER['REQUEST_METHOD']);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "budget";

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);

if (!$conn) {
    // If connection fails, return error JSON
    echo json_encode(array("error" => "Failed to connect to database"));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $trip_id = $_GET['trip_id']; // Assuming you're passing incomeId via GET request
    // SQL to calculate total spent for the given incomeId
    $sql = "SELECT SUM(amount) AS total_spent FROM trip_spent WHERE trip_id = $trip_id";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $totalSpent = $row['total_spent'];
        // Return total spent as JSON response
        echo json_encode(['totalSpent' => $totalSpent]);
    } else {
        // No records found
        echo json_encode(['totalSpent' => 0]); // Or any default value you want
    }
} else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle the insert/update/delete actions
    $data = json_decode(file_get_contents("php://input"));

    // Check if JSON decoding fails
    if (!$data) {
        echo json_encode(array("error" => "Failed to decode JSON data"));
        exit;
    }

    // Handle other POST operations...
    // Your existing code for handling POST requests goes here

} else {
    // For unsupported request methods, return error JSON
    echo json_encode(array("error" => "Invalid request method"));
}




// Close database connection
mysqli_close($conn);
?>
