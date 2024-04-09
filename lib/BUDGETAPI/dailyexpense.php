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
function createRecord($data) {
    $conn = connectToDatabase();

    $date = $data['date'];
    $remarks = $data['remarks'];
    $category = $data['category'];
    $amount = $data['amount'];
    $incomeId = $data['incomeId'];
    $uid = $data['uid'];
    $fromDate = $data['fromDate']; // Adjusted variable name
    $toDate = $data['toDate'];// Adjusted variable name

    $sql = "INSERT INTO daily_expense (date, remarks, category, amount, incomeId, fromDate, toDate, uid)
                   VALUES ('$date', '$remarks','$category', '$amount', '$incomeId', '$fromDate', '$toDate', '$uid')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(array("message" => "New record created successfully"));
    } else {
        echo json_encode(array("error" => "Error: " . $sql . "<br>" . $conn->error));
    }

    $conn->close();
}

// Read Records (SELECT operation)
function readRecords($incomeId) {
    $conn = connectToDatabase();

    $sql = "SELECT id, date, category, remarks, amount FROM daily_expense WHERE incomeId = '$incomeId'";
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
function updateRecord($data) {
    $conn = connectToDatabase();

    $id_to_update = $data['id'];
    $category = $data['category'];
    $amount = $data['amount'];

    $sql = "UPDATE daily_expense SET category='$category',amount='$amount' WHERE id='$id_to_update'";

    if ($conn->query($sql) === TRUE) {
        echo "Record updated successfully";
    } else {
        echo "Error updating record: " . $conn->error;
    }

    $conn->close();
}

// Delete Record (DELETE operation)
function deleteRecord($data) {
    $conn = connectToDatabase();

    $id_to_delete = $data['id'];

    $sql = "DELETE FROM daily_expense WHERE id=$id_to_delete";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(array("message" => "Record deleted successfully"));
    } else {
        echo json_encode(array("error" => "Error deleting record: " . $conn->error));
    }

    $conn->close();
}

// Handle incoming HTTP requests
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);

    createRecord($data);
}
elseif ($_SERVER["REQUEST_METHOD"] === "GET") {
    if (isset($_GET['incomeId'])) {
        $incomeId = $_GET['incomeId'];
        readRecords($incomeId);
    } else {
        echo json_encode(array("error" => "IncomeId parameter is missing"));
    }
} elseif ($_SERVER["REQUEST_METHOD"] === "PUT") {
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);

    updateRecord($data);
} elseif ($_SERVER["REQUEST_METHOD"] === "DELETE") {
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);

    deleteRecord($data);
} else {
    echo json_encode(array("error" => "Invalid request method"));
}
?>
