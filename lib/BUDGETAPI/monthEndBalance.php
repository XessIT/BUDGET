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

       $incomeType = mysqli_real_escape_string($conn, $data->incomeType);
       $uid = mysqli_real_escape_string($conn, $data->uid);
       $incomeAmt = mysqli_real_escape_string($conn, $data->incomeAmt);
       $fromDate = mysqli_real_escape_string($conn, $data->fromDate);
       $toDate = mysqli_real_escape_string($conn, $data->toDate);

           $insertUserQuery = "INSERT INTO `monthly_expenses`(`incomeType`,`uid`,`incomeAmt`,`fromDate`,`toDate`)
          VALUES ('$incomeType','$uid','$incomeAmt','$fromDate','$toDate')";
          $arr = [];
          $insertUserResult = mysqli_query($conn, $insertUserQuery);
          if($insertUserResult) {
             $arr["Success"] = true;
          } else {
             $arr["Success"] = false;
          }
          echo json_encode($arr);
}

else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $uid = $_GET['uid'];

    $query = "SELECT fromDate, toDate, monthRemaining, SUM(getRemaining) as totalEnteredAmount FROM monthly_expenses WHERE uid = '$uid' GROUP BY fromDate, toDate";
    $result = mysqli_query($conn, $query);

    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }

    echo json_encode($data);
}


else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents("php://input"));

    if (isset($data->uid) && isset($data->fromDate) && isset($data->toDate) && isset($data->monthRemaining) && isset($data->enteredAmount)) {
        $uid = mysqli_real_escape_string($conn, $data->uid);
        $fromDate = mysqli_real_escape_string($conn, $data->fromDate);
        $toDate = mysqli_real_escape_string($conn, $data->toDate);
        $monthRemaining = mysqli_real_escape_string($conn, $data->monthRemaining);
        $enteredAmount = mysqli_real_escape_string($conn, $data->enteredAmount);


        // Update monthRemaining based on uid, fromDate, and toDate
        $query = "UPDATE monthly_expenses SET monthRemaining = '$monthRemaining', getRemaining = getRemaining + '$enteredAmount' WHERE uid = '$uid' AND fromDate = '$fromDate' AND toDate = '$toDate'";
        $result = mysqli_query($conn, $query);

        if ($result) {
            echo json_encode(array("message" => "MonthRemaining updated successfully"));
        } else {
            echo json_encode(array("error" => "Failed to update monthRemaining"));
        }
    }
    else if (isset($data->incomeId) && isset($data->monthRemaining)) {
        $incomeId = mysqli_real_escape_string($conn, $data->incomeId);
        $monthRemaining = mysqli_real_escape_string($conn, $data->monthRemaining);

        // Update monthRemaining based on incomeId
        $query = "UPDATE monthly_expenses SET monthRemaining = '$monthRemaining' WHERE incomeId = '$incomeId'";
        $result = mysqli_query($conn, $query);

        if ($result) {
            echo json_encode(array("message" => "Record updated successfully"));
        } else {
            echo json_encode(array("error" => "Failed to update record"));
        }
    } else {
        echo json_encode(array("error" => "Invalid parameters"));
    }
}

$conn->close();
?>
