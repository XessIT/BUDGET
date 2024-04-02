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






// Read Records (SELECT operation)
function readRecords() {
    $conn = connectToDatabase();
     $category = "Daily Expenses"; // Specify the category you want to fetch

    $sql = "SELECT uid, incomeId, fromDate, toDate, category,
                  CASE WHEN COUNT(*) > 1 THEN SUM(amount) ELSE amount END AS totalAmount
           FROM monthly_expenses
           WHERE status = 'open'
           GROUP BY uid, incomeId, fromDate, toDate, category";

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

// Update Record (UPDATE operation)

function updateRecord2($data) {
    $conn = connectToDatabase();

    $incomeId = $data['incomeId'];
    $remaining = $data['remaining'];

    $sql = "UPDATE daily_expense SET remaining='$remaining' WHERE incomeId='$incomeId'";

    if ($conn->query($sql) === TRUE) {
        echo "Record updated successfully";
    } else {
        echo "Error updating record: " . $conn->error;
    }

    $conn->close();
}


// Delete Record (DELETE operation)


// Handle incoming HTTP requests
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    readRecords();
}
elseif ($_SERVER["REQUEST_METHOD"] === "PUT") {
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);

    updateRecord2($data);
}

else {
    echo json_encode(array("error" => "Invalid request method"));
}

?>

