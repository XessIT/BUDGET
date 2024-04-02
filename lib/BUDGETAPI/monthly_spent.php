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
    $data = json_decode(file_get_contents("php://input"), true);

    // Extract data from JSON
    $monthlyExpenses = $data['monthlyexpenses'];
    $fromDate = $data['fromDate'];
    $toDate = $data['toDate'];
    $uid = $data['uid'];
    $incomeId = $data['incomeId'];
    $totalIncomeAmt = $data['totalIncomeAmt'];

    // Loop through the data and insert into the database
    foreach ($monthlyExpenses as $expense) {
        $date = $expense['date'];
        $formatted_date = date('Y-m-d', strtotime($date));
        $category = $expense['category'];
        $amount = $expense['amount'];
        $remarks = $expense['remarks'];

        // Insert into the database
        $sql = "INSERT INTO monthly_expenses (date, category, amount, remarks, fromDate, toDate, uid, incomeId, total_income) VALUES ('$formatted_date', '$category', '$amount', '$remarks', '$fromDate', '$toDate', '$uid', '$incomeId', '$totalIncomeAmt')";
        if ($conn->query($sql) !== TRUE) {
            echo "Error: " . $sql . "<br>" . $conn->error;
        }
    }
}
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $incomeId = $_GET['incomeId']; // Assuming you're passing incomeId via GET request
    // SQL to calculate total spent for the given incomeId
    $sql = "SELECT SUM(amount) AS total_spent FROM monthly_expenses WHERE incomeId = $incomeId";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $totalSpent = $row['total_spent'];
        // Return total spent as JSON response
        echo json_encode(['totalSpent' => $totalSpent]);
    } else {
        // No records found
        echo json_encode(['totalSpent' => 0]); // Or any default value you want
    }
}
else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
      // Parse JSON payload from the request
      $data = json_decode(file_get_contents("php://input"));
      // Escape and sanitize data
      $date = mysqli_real_escape_string($conn, $data->date);
      $category = mysqli_real_escape_string($conn, $data->category);
      $amount = mysqli_real_escape_string($conn, $data->amount);
      $remarks = mysqli_real_escape_string($conn, $data->remarks);
      $id = mysqli_real_escape_string($conn, $data->id);
      // Update query
      $updateQuery = "UPDATE monthly_expenses SET
       date = '$date',
       category = '$category',
       amount = '$amount',
       remarks = '$remarks'
       WHERE id = $id";
        if (mysqli_query($conn, $updateQuery)) {
          echo "Record updated successfully";
      } else {
          echo "Error updating record: " . mysqli_error($conn);
      }
  }
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
      $id = isset($_GET['id']) ? $_GET['id'] : null;

      if (!$id) {
          echo json_encode(array("error" => "ID is missing in the request"));
          exit;
      }

      $id = mysqli_real_escape_string($conn, $id);

      $sql = "DELETE FROM monthly_expenses WHERE id = '$id'";
      $result = $conn->query($sql);

      if ($result === false) {
          echo json_encode(array("error" => "Query failed: " . $conn->error));
      } else {
          echo json_encode(array("message" => "Meeting Type deleted successfully"));
      }
  }


$conn->close();
?>
