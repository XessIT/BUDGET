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

}





else if ($_SERVER['REQUEST_METHOD'] === 'POST') {

}

else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {

}

else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {

}


mysqli_close($conn);
?>