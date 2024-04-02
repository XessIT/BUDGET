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

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Assuming $conn is your database connection
   function readRecords($trip_id) {
       $conn = connectToDatabase();

       $sql = "SELECT id, date, categories, remark, amount FROM trip_spent WHERE trip_id = '$trip_id'";
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
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle the insert/update/delete actions
    $data = json_decode(file_get_contents("php://input"), true);

    // Extract data from JSON
    $tripspent = $data['tripspent'];
    $uid = $data['uid'];
    $trip_id = $data['trip_id'];
    $createdOn = date("Y-m-d H:i:s");

    // Loop through the data and insert into the database
    foreach ($tripspent as $expense) {
        $date = $expense['date'];
        $formatted_date = date('Y-m-d', strtotime($date));
        $categories = $expense['category'];
        $amount = $expense['amount'];
        $remark = $expense['remark'];
        // Insert into the database
        $sql = "INSERT INTO trip_spent (date, categories, amount, remark, uid, trip_id, createdOn) VALUES ('$formatted_date', '$categories', '$amount', '$remark', '$uid', '$trip_id', '$createdOn')";
        if ($conn->query($sql) !== TRUE) {
            echo json_encode(array("error" => "Error: " . $conn->error));
            exit;
        }
    }
    echo json_encode(array("success" => "Data inserted successfully"));
} else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        // Parse JSON payload from the request
        $data = json_decode(file_get_contents("php://input"));
        // Escape and sanitize data
        $date = mysqli_real_escape_string($conn, $data->date);
        $categories = mysqli_real_escape_string($conn, $data->categories);
        $amount = mysqli_real_escape_string($conn, $data->amount);
        $remark = mysqli_real_escape_string($conn, $data->remark);
        $id = mysqli_real_escape_string($conn, $data->id);
        // Update query
        $updateQuery = "UPDATE trip_spent SET
         date = '$date',
         categories = '$categories',
         amount = '$amount',
         remark = '$remark'
         WHERE id = $id";
          if (mysqli_query($conn, $updateQuery)) {
            echo "Record updated successfully";
        } else {
            echo "Error updating record: " . mysqli_error($conn);
        }
    }
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
      $id = isset($_GET['id']) ? $_GET['id'] : null;

      if (!$id) {
          echo json_encode(array("error" => "ID is missing in the request"));
          exit;
      }

      $id = mysqli_real_escape_string($conn, $id);

      $sql = "DELETE FROM trip_spent WHERE id = '$id'";
      $result = $conn->query($sql);

      if ($result === false) {
          echo json_encode(array("error" => "Query failed: " . $conn->error));
      } else {
          echo json_encode(array("message" => "Meeting Type deleted successfully"));
      }
  }

mysqli_close($conn);
?>
