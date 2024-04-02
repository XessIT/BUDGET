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
   $table = isset($_GET['table']) ? $_GET['table'] : "";
    if ($table == "trip_creation") {
    $uid = isset($_GET['uid']) ? mysqli_real_escape_string($conn, $_GET['uid']) : "";
    $trip_id = isset($_GET['trip_id']) ? mysqli_real_escape_string($conn, $_GET['trip_id']) : "";

            $offerlist = "SELECT * FROM trip_creation where uid ='$uid' AND trip_id = '$trip_id'";

            $offerResult = mysqli_query($conn, $offerlist);
            if ($offerResult && mysqli_num_rows($offerResult) > 0) {
                $offers = array();
                while ($row = mysqli_fetch_assoc($offerResult)) {
                    $offers[] = $row;
                               }
                echo json_encode($offers);
            } else {
                echo json_encode(array("message" => "No offers found"));
            }
    } else if ($table == "trip_members") {
    $trip_id = isset($_GET['trip_id']) ? mysqli_real_escape_string($conn, $_GET['trip_id']) : "";
                        $registrationlist = "SELECT * FROM trip_members where trip_id = '$trip_id'";

                        $registrationResult = mysqli_query($conn, $registrationlist);
                        if ($registrationResult && mysqli_num_rows($registrationResult) > 0) {
                            $registrations = array();
                            while ($row = mysqli_fetch_assoc($registrationResult)) {
                                $registrations[] = $row;
                            }
                            echo json_encode($registrations);
                        } else {
                            echo json_encode(array("message" => "No registrations found"));
                        }
             } else {
                       echo json_encode(array("message" => "Invalid table name"));
                       exit;
                   }
}
/*

else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle the insert/update/delete actions
   $data = json_decode(file_get_contents("php://input"));

   $trip_name = mysqli_real_escape_string($conn, $data->trip_name);
   $trip_type = mysqli_real_escape_string($conn, $data->trip_type);
   $location = mysqli_real_escape_string($conn, $data->location);
   $from_date = mysqli_real_escape_string($conn, $data->from_date);
   $to_date = mysqli_real_escape_string($conn, $data->to_date);
   $budget = mysqli_real_escape_string($conn, $data->budget);
   $members = mysqli_real_escape_string($conn, $data->members);
   $user_id = mysqli_real_escape_string($conn, $data->user_id);
   $trip_id = mysqli_real_escape_string($conn, $data->trip_id);
   $member_name = mysqli_real_escape_string($conn, $data->member_name);
   $mobile = mysqli_real_escape_string($conn, $data->mobile);
   $amount = mysqli_real_escape_string($conn, $data->amount);
   $createdOn = mysqli_real_escape_string($conn, $data->createdOn);

       $insertUserQuery = "INSERT INTO `trip_creation`(`trip_type`, `trip_name`, `location`, `from_date`, `to_date`, `budget`, `members`, `user_id`, `trip_id`, `member_name`, `mobile`, `amount`, `createdOn`)
       VALUES ('$trip_type','$trip_name','$location','$from_date','$to_date','$budget','$members','$user_id','$trip_id','$member_name','$mobile','$amount','$createdOn')";

      $arr = [];
      $insertUserResult = mysqli_query($conn, $insertUserQuery);
      if($insertUserResult) {
         $arr["Success"] = true;
      } else {
         $arr["Success"] = false;
      }
      echo json_encode($arr);

}
 */
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle the insert/update/delete actions
    $data = json_decode(file_get_contents("php://input"), true);

    // Extract data from JSON
    $tripspent = $data['tripspent'];

    $trip_id = $data['trip_id'];


    // Loop through the data and insert into the database
    foreach ($tripspent as $expense) {
        $name = $expense['member_name'];
        $amount = $expense['mobile'];
        $remark = $expense['amount'];
        // Insert into the database
        $sql = "INSERT INTO trip_members ( member_name, mobile, amount,trip_id) VALUES ('$member_name', '$mobile', '$amount', '$trip_id')";
        if ($conn->query($sql) !== TRUE) {
            echo json_encode(array("error" => "Error: " . $conn->error));
            exit;
        }
    }
    echo json_encode(array("success" => "Data inserted successfully"));
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

      $sql = "DELETE FROM trip_members WHERE id = '$id'";
      $result = $conn->query($sql);

      if ($result === false) {
          echo json_encode(array("error" => "Query failed: " . $conn->error));
      } else {
          echo json_encode(array("message" => "Meeting Type deleted successfully"));
      }
  }




mysqli_close($conn);
?>