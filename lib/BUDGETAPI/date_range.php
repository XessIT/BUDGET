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
   $data = json_decode(file_get_contents("php://input"));

   $uid = mysqli_real_escape_string($conn, $data->uid);
   $fromDate = mysqli_real_escape_string($conn, $data->fromDate);
  // $toDate = mysqli_real_escape_string($conn, $data->toDate);

       $insertUserQuery = "INSERT INTO `monthly_daterange`(`uid`,`fromDate`)
      VALUES ('$uid','$fromDate')";
      $arr = [];
      $insertUserResult = mysqli_query($conn, $insertUserQuery);
      if($insertUserResult) {
         $arr["Success"] = true;
      } else {
         $arr["Success"] = false;
      }
      echo json_encode($arr);
}


mysqli_close($conn);
?>