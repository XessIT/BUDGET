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
       if ($table == "monthly_credit") {
   $uid = isset($_GET['uid']) ? mysqli_real_escape_string($conn, $_GET['uid']) : "";

   // Fetch data from the registration table
   $registrationlist = "SELECT * FROM monthly_credit WHERE uid='$uid'";
   $registrationResult = mysqli_query($conn, $registrationlist);
   if ($registrationResult) {
       if (mysqli_num_rows($registrationResult) > 0) {
           $registrations = array();
           while ($row = mysqli_fetch_assoc($registrationResult)) {
               $registrations[] = $row;
           }
           echo json_encode($registrations);
       } else {
           echo json_encode(array("message" => "No registrations found for UID: $uid"));
       }
   } else {
       echo json_encode(array("error" => mysqli_error($conn)));
   }
 }
 elseif ($table == "monthly_expenses") {
     $uid = isset($_GET['uid']) ? mysqli_real_escape_string($conn, $_GET['uid']) : "";
     $incomeId = isset($_GET['incomeId']) ? mysqli_real_escape_string($conn, $_GET['incomeId']) : "";

        // Fetch data from the registration table
        $registrationlist = "SELECT * FROM monthly_expenses WHERE uid='$uid' and incomeId = '$incomeId'";
        $registrationResult = mysqli_query($conn, $registrationlist);
        if ($registrationResult) {
            if (mysqli_num_rows($registrationResult) > 0) {
                $registrations = array();
                while ($row = mysqli_fetch_assoc($registrationResult)) {
                    $registrations[] = $row;
                }
                echo json_encode($registrations);
            } else {
                echo json_encode(array("message" => "No registrations found for UID: $uid"));
            }
        } else {
            echo json_encode(array("error" => mysqli_error($conn)));
        }
              } else {
                        echo json_encode(array("message" => "Invalid table name"));
                        exit;
                    }

}

else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle the insert/update/delete actions
   $data = json_decode(file_get_contents("php://input"));
   $imagename = mysqli_real_escape_string($conn, $data->imagename);
    echo "Imagename: $imagename";
   $imagedata = mysqli_real_escape_string($conn, $data->imagedata);
   $name = mysqli_real_escape_string($conn, $data->name);
   $discount = mysqli_real_escape_string($conn, $data->discount);
   $user_id = mysqli_real_escape_string($conn, $data->user_id);
   $offer_type = mysqli_real_escape_string($conn, $data->offer_type);
   $validity = mysqli_real_escape_string($conn, $data->validity);
   $first_name = mysqli_real_escape_string($conn, $data->first_name);
   $last_name = mysqli_real_escape_string($conn, $data->last_name);
   $mobile = mysqli_real_escape_string($conn, $data->mobile);
   $company_name = mysqli_real_escape_string($conn, $data->company_name);
   $block_status = mysqli_real_escape_string($conn, $data->block_status);
    $path = "offers/$imagename";
       $insertUserQuery = "INSERT INTO `offers`(`user_id`, `offer_type`, `name`, `discount`, `validity`, `first_name`, `last_name`, `mobile`, `company_name`, `block_status`, `offer_image`)
      VALUES ('$user_id','$offer_type','$name','$discount','$validity', '$first_name', '$last_name', '$mobile', '$company_name', '$block_status', '$path')";
      file_put_contents($path, base64_decode($imagedata));
      $arr = [];
      $insertUserResult = mysqli_query($conn, $insertUserQuery);
      if($insertUserResult) {
         $arr["Success"] = true;
      } else {
         $arr["Success"] = false;
      }
      echo json_encode($arr);

}

else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));

    // Check if block_status is provided
    if(isset($data->block_status)) {
        $ID = mysqli_real_escape_string($conn, $data->ID);
        $block_status = mysqli_real_escape_string($conn, $data->block_status);

        $updateBlockStatusQuery = "UPDATE `offers` SET `block_status`='$block_status' WHERE `ID`='$ID'";
        $updateBlockStatusResult = mysqli_query($conn, $updateBlockStatusQuery);

        if ($updateBlockStatusResult) {
            echo "Offer blocked/unblocked successfully";
        } else {
            echo "Error: " . mysqli_error($conn);
        }
    } else {
        // Handle the insert/update actions for editing an offer
        $name = mysqli_real_escape_string($conn, $data->name);
        $discount = mysqli_real_escape_string($conn, $data->discount);
        $ID = mysqli_real_escape_string($conn, $data->ID);
        $offer_type = mysqli_real_escape_string($conn, $data->offer_type);
        $validity = mysqli_real_escape_string($conn, $data->validity);

        $updateOfferQuery = "UPDATE `offers` SET `offer_type`='$offer_type', `name`='$name', `discount`='$discount', `validity`='$validity' WHERE `ID`='$ID'";
        $updateOfferResult = mysqli_query($conn, $updateOfferQuery);

        if ($updateOfferResult) {
            echo "Offer updated successfully";
        } else {
            echo "Error: " . mysqli_error($conn);
        }
    }
}

else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $ID = isset($_GET['ID']) ? $_GET['ID'] : null;

    if (!$ID) {
        echo json_encode(array("error" => "ID is missing in the request"));
        exit;
    }

    $ID = mysqli_real_escape_string($conn, $ID);

    $sql = "DELETE FROM offers WHERE ID = '$ID'";
    $result = $conn->query($sql);

    if ($result === false) {
        echo json_encode(array("error" => "Query failed: " . $conn->error));
    } else {
        echo json_encode(array("message" => "Offer deleted successfully"));
    }
}


mysqli_close($conn);
?>