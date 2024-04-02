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
    $incomeId = isset($_GET['incomeId']) ? $_GET['incomeId'] : null;

    if (!$incomeId) {
        echo json_encode(array("error" => "Income ID is missing in the request"));
        exit;
    }

    $incomeId = mysqli_real_escape_string($conn, $incomeId);

    // Query to get the total incomeAmt, fromDate, and toDate from both tables for the given incomeId
    $query = "
        SELECT SUM(incomeAmt) AS totalIncomeAmt, MIN(fromDate) AS fromDate, MAX(toDate) AS toDate
        FROM (
            SELECT incomeAmt, fromDate, toDate FROM monthly_credit WHERE incomeId = '$incomeId'
            UNION ALL
            SELECT incomeAmt, NULL AS fromDate, NULL AS toDate FROM add_credit WHERE incomeId = '$incomeId'
        ) AS combined_income
    ";

    $result = mysqli_query($conn, $query);

    if ($result) {
        $row = mysqli_fetch_assoc($result);
        $response = array(
            "incomeAmt" => $row['totalIncomeAmt'],
            "fromDate" => $row['fromDate'],
            "toDate" => $row['toDate']
        );
        echo json_encode($response);
    } else {
        echo json_encode(array("error" => "Failed to fetch data"));
    }
}



else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
   $data = json_decode(file_get_contents("php://input"));

   $incomeType = mysqli_real_escape_string($conn, $data->incomeType);
   $incomeAmt = mysqli_real_escape_string($conn, $data->incomeAmt);
   $incomeId = mysqli_real_escape_string($conn, $data->incomeId);

       $insertUserQuery = "INSERT INTO `add_credit`(`incomeType`,`incomeId`,`incomeAmt`)
      VALUES ('$incomeType','$incomeId','$incomeAmt')";
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