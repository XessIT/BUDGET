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
    if (isset($_GET['uid'])) {
        $uid = mysqli_real_escape_string($conn, $_GET['uid']);

        $selectDateRangeQuery = "SELECT `fromDate` FROM `monthly_daterange` WHERE `uid`='$uid'";
        $result = mysqli_query($conn, $selectDateRangeQuery);

        if ($result) {
            $dateRange = mysqli_fetch_assoc($result);
            echo json_encode($dateRange);
        } else {
            echo json_encode(["error" => "Failed to fetch date range."]);
        }
    } else {
        echo json_encode(["error" => "UID not provided."]);
    }
}




mysqli_close($conn);
?>