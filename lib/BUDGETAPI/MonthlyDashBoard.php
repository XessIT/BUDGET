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
/* if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $response = array();

    // Query to fetch data from monthly_credit table along with totalIncomeAmt, fromDate, toDate, incomeType, and status
    $query = "
        SELECT incomeId, uid, SUM(incomeAmt) AS totalIncomeAmt, MIN(fromDate) AS fromDate, MAX(toDate) AS toDate, incomeType, status
        FROM (
            SELECT incomeId, uid, incomeAmt, fromDate, toDate, incomeType, status FROM monthly_credit
            WHERE status='open'  -- Filter the results based on status='open'
            UNION ALL
            SELECT incomeId, NULL AS uid, incomeAmt, NULL AS fromDate, NULL AS toDate, incomeType, NULL AS status FROM add_credit
        ) AS combined_income
        GROUP BY incomeId
    ";
    $result = mysqli_query($conn, $query);

    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            $data = array(
                "incomeId" => $row['incomeId'],
                "uid" => $row['uid'], // Include uid in the response
                "fromDate" => $row['fromDate'],
                "toDate" => $row['toDate'],
                "totalIncomeAmt" => $row['totalIncomeAmt'],
                "incomeType" => $row['incomeType'], // Include incomeType in the response
                //"status" => $row['status'] // Include status in the response
            );
            $response[] = $data;
        }
        echo json_encode($response);
    } else {
        echo json_encode(array("error" => "Failed to fetch data"));
    }
} */
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $response = array();
    // Query to fetch data from monthly_credit table along with totalIncomeAmt, fromDate, toDate, incomeType, and status
    $query = "
        SELECT
            mc.incomeId,
            mc.uid,
            mc.totalIncomeAmt,
            mc.fromDate,
            mc.toDate,
            mc.incomeType,
            mc.status,
            IFNULL(me.total_spent, 0) AS total_spent -- Calculate total spent from monthly_expenses
        FROM (
            SELECT incomeId, uid, SUM(incomeAmt) AS totalIncomeAmt, MIN(fromDate) AS fromDate, MAX(toDate) AS toDate, incomeType, status
            FROM (
                SELECT incomeId, uid, incomeAmt, fromDate, toDate, incomeType, status FROM monthly_credit
                WHERE status='open'  -- Filter the results based on status='open'
                UNION ALL
                SELECT incomeId, NULL AS uid, incomeAmt, NULL AS fromDate, NULL AS toDate, incomeType, NULL AS status FROM add_credit
            ) AS combined_income
            GROUP BY incomeId
        ) AS mc
        LEFT JOIN (
            SELECT incomeId, SUM(amount) AS total_spent
            FROM monthly_expenses
            GROUP BY incomeId
        ) AS me ON mc.incomeId = me.incomeId
    ";
    $result = mysqli_query($conn, $query);

    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            // Calculate remaining
            $remaining = $row['totalIncomeAmt'] - $row['total_spent'];

            // Add data to response
            $data = array(
                "incomeId" => $row['incomeId'],
                "uid" => $row['uid'], // Include uid in the response
                "fromDate" => $row['fromDate'],
                "toDate" => $row['toDate'],
                "totalIncomeAmt" => $row['totalIncomeAmt'],
                "incomeType" => $row['incomeType'], // Include incomeType in the response
                //"status" => $row['status'], // Include status in the response
                "total_spent" => $row['total_spent'], // Include total_spent in the response
                "remaining" => $remaining // Include remaining in the response
            );
            $response[] = $data;
        }
        echo json_encode($response);
    } else {
        echo json_encode(array("error" => "Failed to fetch data"));
    }
}



else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
$table = isset($_GET['table']) ? $_GET['table'] : "";
 if ($table == "monthly_dashboard") {
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
 elseif ($table == "add_wallet_amount") {
   $data = json_decode(file_get_contents("php://input"));

   // Extract data from the request
   $incomeId = $data->incomeId;
   $incomeAmt = $data->incomeAmt;

   // Retrieve the current value of incomeAmt from the database
   $query = "SELECT incomeAmt FROM monthly_credit WHERE incomeId = '$incomeId'";
   $result = mysqli_query($conn, $query);

   if ($result && mysqli_num_rows($result) > 0) {
       $row = mysqli_fetch_assoc($result);
       $currentIncomeAmt = $row['incomeAmt'];

       // Calculate the new value of incomeAmt by adding the input amount
       $newIncomeAmt = $currentIncomeAmt + $incomeAmt;

       // Update the monthly_credit table with the new incomeAmt value
       $updateQuery = "UPDATE monthly_credit SET incomeAmt = '$newIncomeAmt' WHERE incomeId = '$incomeId'";
       $updateResult = mysqli_query($conn, $updateQuery);

       if ($updateResult) {
           echo json_encode(array("message" => "Record updated successfully"));
       } else {
           echo json_encode(array("error" => "Failed to update record"));
       }
   } else {
       echo json_encode(array("error" => "Record not found"));
   }
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