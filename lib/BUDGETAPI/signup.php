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
    // Handle the insert/update/delete actions
   $data = json_decode(file_get_contents("php://input"));
   
   
    
   $user_name = mysqli_real_escape_string($conn, $data->user_name);
   $mobile = mysqli_real_escape_string($conn, $data->mobile);
   $company_name = mysqli_real_escape_string($conn, $data->company_name);
   $address = mysqli_real_escape_string($conn, $data->address);
   $otp = mysqli_real_escape_string($conn, $data->otp);

     
                  // Insert offer data into the database
                  $insertUserQuery = "INSERT INTO `signup`(`user_name`, `mobile`, `company_name`, `address`,`otp`)
                      VALUES ('$user_name','$mobile','$company_name', '$address','$otp')";
                  $insertUserResult = mysqli_query($conn, $insertUserQuery);

      if ($insertUserResult) {
          echo json_encode(["success" => true, "message" => "Signup stored successfully"]);
      } else {
          echo json_encode(["success" => false, "message" => "Error: " . mysqli_error($conn)]);
      }

}
else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));

    // Check if block_status is provided

        $id = mysqli_real_escape_string($conn, $data->id);
        $otp = mysqli_real_escape_string($conn, $data->otp);
        $datetime = mysqli_real_escape_string($conn, $data->datetime);

    $updateotpStatusQuery = "UPDATE `signup` SET `otp`='$otp',`datetime`='$datetime' WHERE `id`='$id'";
        $updateotpStatusResult = mysqli_query($conn, $updateotpStatusQuery);

        if ($updateotpStatusResult) {
            echo "OTP update successfully";
        } else {
            echo "Error: " . mysqli_error($conn);
        }

}
else if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $mobile = isset($_GET['mobile']) ? mysqli_real_escape_string($conn, $_GET['mobile']) : "";

                        $registrationlist = "SELECT * FROM signup where mobile='$mobile'";


                        $registrationResult = mysqli_query($conn, $registrationlist);
                        if ($registrationResult && mysqli_num_rows($registrationResult) > 0) {
                            $registrations = array();
                            while ($row = mysqli_fetch_assoc($registrationResult)) {
                                $registrations[] = $row;
                            }
                            echo json_encode($registrations);
                        } else {
                            echo json_encode(array("message" => "No Signup found"));
                        }
             } else {
                       echo json_encode(array("message" => "Invalid table name"));
                       exit;
           }





mysqli_close($conn);
?>