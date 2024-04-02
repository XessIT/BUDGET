

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
    // Assuming $conn is your database connection
    $query = "SELECT * FROM `trip_creation`";
    $result = mysqli_query($conn, $query);

    if ($result) {
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        // If query execution fails, return error JSON
        echo json_encode(array("error" => "Failed to fetch data"));
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
