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
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle the insert action
    $data = json_decode(file_get_contents("php://input"), true);

    // Check if 'tripspent' key exists in the received JSON data
    if (isset($data['tripspent'])) {
        // Extract 'tripspent' data from JSON
        $tripspent = $data['tripspent'];
        $trip_id = $data['trip_id'];

        // Loop through the 'tripspent' data and insert into the database
        foreach ($tripspent as $expense) {
            $member_name = $expense['member_name'];
            $mobile = $expense['mobile'];
            $perAmount = $expense['amount'];
            // Insert into the database
            $sql = "INSERT INTO trip_members (member_name, mobile, amount, trip_id) VALUES ('$member_name', '$mobile', '$perAmount', '$trip_id')";
            if ($conn->query($sql) !== TRUE) {
                echo json_encode(array("error" => "Error: " . $conn->error));
                exit;
            }
        }
        echo json_encode(array("success" => "Data inserted successfully"));
    } else {
        // Handle case when 'tripspent' key is not present in the received JSON data
        echo json_encode(array("error" => "'tripspent' key is missing in the request"));
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $incomeId = $_GET['incomeId']; // Assuming you're passing incomeId via GET request
    // SQL to calculate total spent for the given incomeId
    $sql = "SELECT SUM(amount) AS total_spent FROM monthly_expenses WHERE incomeId = $incomeId";
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
}

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));

    // Assuming the unique trip_id is provided in the incoming data
    $trip_id = mysqli_real_escape_string($conn, $data->trip_id);

    // Escape and retrieve data from JSON object
    $trip_name = mysqli_real_escape_string($conn, $data->trip_name);
    $trip_type = mysqli_real_escape_string($conn, $data->trip_type);
    $location = mysqli_real_escape_string($conn, $data->location);
    $from_date = mysqli_real_escape_string($conn, $data->from_date);
    $to_date = mysqli_real_escape_string($conn, $data->to_date);
    $budget = mysqli_real_escape_string($conn, $data->budget);
    $members = mysqli_real_escape_string($conn, $data->members);
    $uid = mysqli_real_escape_string($conn, $data->uid);
    $createdOn = mysqli_real_escape_string($conn, $data->createdOn);

    // Update the trip data based on the provided trip_id
    $updateTripQuery = "UPDATE `trip_creation` SET `trip_type`='$trip_type', `trip_name`='$trip_name', `location`='$location', `from_date`='$from_date', `to_date`='$to_date', `budget`='$budget', `members`='$members', `uid`='$uid', `createdOn`='$createdOn' WHERE `trip_id`='$trip_id'";

    $updateTripResult = mysqli_query($conn, $updateTripQuery);

    if ($updateTripResult) {
        // If the trip update was successful, update member data
        if (isset($data->members_data)) {
            foreach ($data->members_data as $member) {
                $member_name = mysqli_real_escape_string($conn, $member->name);
                $mobile = mysqli_real_escape_string($conn, $member->mobile);
                $amount = mysqli_real_escape_string($conn, $member->amount);
                $id = mysqli_real_escape_string($conn, $member->id);

                // Update member data based on the provided trip_id
                $updateMemberQuery = "UPDATE `trip_members` SET `member_name`='$member_name', `mobile`='$mobile', `amount`='$amount' WHERE `trip_id`='$trip_id' AND `id`='$id'";

                $updateMemberResult = mysqli_query($conn, $updateMemberQuery);

                if (!$updateMemberResult) {
                    echo json_encode(array("Success" => false, "message" => "Failed to update member data"));
                    exit();
                }
            }
        }

        echo json_encode(array("Success" => true));
    } else {
        echo json_encode(array("Success" => false, "message" => "Failed to update trip data"));
    }
}


else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
      $id = isset($_GET['id']) ? $_GET['id'] : null;

      if (!$id) {
          echo json_encode(array("error" => "ID is missing in the request"));
          exit;
      }

      $id = mysqli_real_escape_string($conn, $id);

      $sql = "DELETE FROM monthly_expenses WHERE id = '$id'";
      $result = $conn->query($sql);

      if ($result === false) {
          echo json_encode(array("error" => "Query failed: " . $conn->error));
      } else {
          echo json_encode(array("message" => "Meeting Type deleted successfully"));
      }
  }


$conn->close();
?>