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
    $uid = $_GET['uid']; // Assuming you're passing uid via GET request
    $incomeId = $_GET['incomeId']; // Assuming you're passing incomeId via GET request
    // SQL to fetch data from both tables based on uid and incomeId
    $sql = "SELECT monthly_credit.incomeType AS incomeType, monthly_credit.incomeAmt AS incomeAmt
            FROM monthly_credit
            WHERE monthly_credit.uid = $uid AND monthly_credit.incomeId = $incomeId
            UNION
            SELECT add_credit.incomeType AS incomeType, add_credit.incomeAmt AS incomeAmt
            FROM add_credit
            WHERE add_credit.uid = $uid AND add_credit.incomeId = $incomeId";

    $result = $conn->query($sql);
    $data = [];

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        // Return fetched data as JSON response
        echo json_encode(['data' => $data]);
    } else {
        // No records found
        echo json_encode(['data' => []]); // Or any default value you want
    }
}


else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));

    // Extract data from the request
    $incomeId = $data->incomeId;
    $fromDate = $data->fromDate;
    $toDate = $data->toDate;
    $incomeAmt = $data->incomeAmt;
    $incomeType = $data->incomeType;

    // Update the monthly_credit table
    $query = "UPDATE monthly_credit SET fromDate = '$fromDate', toDate = '$toDate', incomeAmt = '$incomeAmt', incomeType = '$incomeType' WHERE incomeId = '$incomeId'";
    $result = mysqli_query($conn, $query);

    if ($result) {
        echo json_encode(array("message" => "Record updated successfully"));
    } else {
        echo json_encode(array("error" => "Failed to update record"));
    }
}

else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
   $data = json_decode(file_get_contents("php://input"));

   $uid = mysqli_real_escape_string($conn, $data->uid);
   $type = mysqli_real_escape_string($conn, $data->type);
   $incomeType = mysqli_real_escape_string($conn, $data->incomeType);
   $incomeAmt = mysqli_real_escape_string($conn, $data->incomeAmt);
   $fromDate = mysqli_real_escape_string($conn, $data->fromDate);
   $toDate = mysqli_real_escape_string($conn, $data->toDate);
   $status = mysqli_real_escape_string($conn, $data->status);

       $insertUserQuery = "INSERT INTO `monthly_credit`(`uid`,`type`,`incomeType`,`incomeAmt`,`fromDate`,`toDate`,`status`)
      VALUES ('$uid','$type','$incomeType','$incomeAmt','$fromDate','$toDate','open')";
      $arr = [];
      $insertUserResult = mysqli_query($conn, $insertUserQuery);
      if($insertUserResult) {
         $arr["Success"] = true;
      } else {
         $arr["Success"] = false;
      }
      echo json_encode($arr);
}

else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $data = json_decode(file_get_contents("php://input"));

    if (isset($data->incomeId)) {
        $incomeId = $data->incomeId;

        // Delete query for removing data based on incomeId from both tables
        $query = "DELETE FROM monthly_credit WHERE incomeId = '$incomeId';";
        $query .= "DELETE FROM add_credit WHERE incomeId = '$incomeId';";

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