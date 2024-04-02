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
    }
    if ($table == "trip_spent") {
          $trip_id = isset($_GET['trip_id']) ? mysqli_real_escape_string($conn, $_GET['trip_id']) : "";

                  $offerlist = "SELECT * FROM trip_spent where trip_id = '$trip_id'";

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
          }elseif ($table == "trip_members") {
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
 if ($_SERVER['REQUEST_METHOD'] === 'POST') {
     $data = json_decode(file_get_contents("php://input"));
    $trip_id = uniqid();

     $trip_name = mysqli_real_escape_string($conn, $data->trip_name);
     $trip_type = mysqli_real_escape_string($conn, $data->trip_type);
     $location = mysqli_real_escape_string($conn, $data->location);
     $from_date = mysqli_real_escape_string($conn, $data->from_date);
     $to_date = mysqli_real_escape_string($conn, $data->to_date);
     $budget = mysqli_real_escape_string($conn, $data->budget);
     $members = mysqli_real_escape_string($conn, $data->members);
     $uid = mysqli_real_escape_string($conn, $data->uid);
     $trip_id = mysqli_real_escape_string($conn, $data->trip_id);
     $received_amount = mysqli_real_escape_string($conn, $data->received_amount);
     $createdOn = mysqli_real_escape_string($conn, $data->createdOn);

     // Assuming your 'trip_creation' table has columns similar to below
     $insertTripQuery = "INSERT INTO `trip_creation`(`trip_type`, `trip_name`, `location`, `from_date`, `to_date`, `budget`, `members`, `uid`, `trip_id`, `received_amount`, `createdOn`)
                        VALUES ('$trip_type','$trip_name','$location','$from_date','$to_date','$budget','$members','$uid','$trip_id','$received_amount','$createdOn')";

     $insertTripResult = mysqli_query($conn, $insertTripQuery);

     if ($insertTripResult) {
         // If the trip insertion was successful, insert member data
         if (isset($data->members_data)) {
             foreach ($data->members_data as $member) {
                 $member_name = mysqli_real_escape_string($conn, $member->name);
                 $mobile = mysqli_real_escape_string($conn, $member->mobile);
                 $amount = mysqli_real_escape_string($conn, $member->amount);

                 // Assuming your 'trip_members' table has columns similar to below
                 $insertMemberQuery = "INSERT INTO `trip_members`(`trip_id`, `member_name`, `mobile`, `amount`)
                                       VALUES ('$trip_id','$member_name','$mobile','$amount')";
                 $insertMemberResult = mysqli_query($conn, $insertMemberQuery);

                 if (!$insertMemberResult) {
                     echo json_encode(array("Success" => false, "message" => "Failed to insert member data"));
                     exit();
                 }
             }
         }

         echo json_encode(array("Success" => true));
     } else {
         echo json_encode(array("Success" => false, "message" => "Failed to insert trip data"));
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
    $received_amount = mysqli_real_escape_string($conn, $data->received_amount);
    $uid = mysqli_real_escape_string($conn, $data->uid);
    $createdOn = mysqli_real_escape_string($conn, $data->createdOn);

    // Update the trip data based on the provided trip_id
    $updateTripQuery = "UPDATE `trip_creation` SET `trip_type`='$trip_type', `trip_name`='$trip_name', `location`='$location', `from_date`='$from_date', `to_date`='$to_date', `budget`='$budget', `members`='$members', `received_amount`='$received_amount',`uid`='$uid', `createdOn`='$createdOn' WHERE `trip_id`='$trip_id'";

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
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
     $data = json_decode(file_get_contents("php://input"));

     if (isset($data->trip_id)) {
         $trip_id = $data->trip_id;

         // Delete query for removing data based on incomeId from both tables
         $query = "DELETE FROM trip_creation WHERE trip_id = '$trip_id';";
         //$query .= "DELETE FROM add_credit WHERE incomeId = '$incomeId';";

         if (mysqli_multi_query($conn, $query)) {
             echo json_encode(array("message" => "Data deleted successfully"));
         } else {
             echo json_encode(array("error" => "Failed to delete data"));
         }
     } else {
         echo json_encode(array("error" => "Income ID is missing"));
     }
}

mysqli_close($conn);
?>