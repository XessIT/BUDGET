<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection function
function connectToDatabase() {
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "budget";

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}

function updateWalletBudgetWithBorrow($uid, $incomeId) {
    $conn = connectToDatabase();
    $borrowAmt = 0;
    $budgetAmt = 0;

    $sqlBorrow = "SELECT * FROM wallet_log WHERE USER_ID = '$uid' AND REVERSE = 'Y'
                  AND BORROW_AMT > 0 AND LOG_DATE BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                  AND CURDATE()";
    $resultBorrow = $conn->query($sqlBorrow);

    while ($row = $resultBorrow->fetch_assoc()) {
        $borrowAmt += $row['BORROW_AMT'];
    }

    $sqlMonthly = "SELECT * FROM monthly_expenses WHERE uid = '$uid' AND incomeId = '$incomeId'
                        AND category = 'Daily Expenses'";
    $resultMonthly = $conn->query($sqlMonthly);

    while ($row = $resultMonthly->fetch_assoc()) {
        $budgetAmt += $row['amount'];
    }

    $total = $budgetAmt - $borrowAmt;

    $sqlWallet = "SELECT * FROM wallet WHERE uid = '$uid'";
    $resultWallet = $conn->query($sqlWallet);
    $walletAmt = 0;

    while ($row = $resultWallet->fetch_assoc()) {
        $walletAmt += $row['wallet'];
    }

    $totalWallet = $walletAmt + $borrowAmt;
    $updateWallet = "UPDATE wallet SET wallet='$totalWallet' WHERE uid='$uid'";

    $conn->query($updateWallet);

    $sql = "UPDATE monthly_expenses SET amount='$total' WHERE uid='$uid' AND incomeId = '$incomeId'
                    AND category = 'Daily Expenses'";

    if ($conn->query($sql) === TRUE) {
        echo "Budget updated successfully";
    } else {
        echo "Budget updating failed: " . $conn->error;
    }

    $conn->close();

}

function updateDailyBudget($conn, $uid, $incomeId, $borrowAmt) {
    $amt = 0;
    $remainingAmt = 0;

    $sqlCheck = "SELECT * FROM monthly_expenses WHERE uid = '$uid' AND incomeId = '$incomeId'
                    AND category = 'Daily Expenses'";
    $result = $conn->query($sqlCheck);

    while ($row = $result->fetch_assoc()) {
        $amt += $row['amount'];
    }

    $amt += $borrowAmt;

    $sql = "UPDATE monthly_expenses SET amount='$amt' WHERE uid='$uid' AND incomeId = '$incomeId'
                AND category = 'Daily Expenses'";

    $conn->query($sql);
}

function borrowWalletUpdate($uid, $incomeId, $borrowAmt, $reverse) {
    $conn = connectToDatabase();
    $amt = 0;
    $remainingAmt = 0;

    $sqlCheck = "SELECT * FROM wallet WHERE uid = '$uid'";
    $result = $conn->query($sqlCheck);

    while ($row = $result->fetch_assoc()) {
        $amt += $row['wallet'];
    }

    $remainingAmt =  $amt - $borrowAmt;

    $sql = "UPDATE wallet SET wallet='$remainingAmt' WHERE uid='$uid'";

    if ($conn->query($sql) === TRUE) {
        echo "Wallet updated successfully";
    } else {
        echo "Wallet updating failed: " . $conn->error;
    }

    updateDailyBudget($conn, $uid, $incomeId, $borrowAmt);
    logWalletInfo($conn, $uid, $borrowAmt, 0, $remainingAmt, $reverse);
}

function lendingWalletUpdate($uid, $lendingAmt, $todate) {
    $conn = connectToDatabase();

    $sqlCheck = "SELECT * FROM wallet WHERE uid = '$uid'";
    $result = $conn->query($sqlCheck);

    $sql = "";
    $amt = 0;
    $total = 0;
    if ($result->num_rows == 0) {
        $total = $lendingAmt;
            $sql = "INSERT INTO wallet (uid, wallet) VALUES ('$uid', '$lendingAmt')";
        } else {
            while ($row = $result->fetch_assoc()) {
                $amt += $row['wallet'];
            }
            $total = $lendingAmt + $amt;
            $sql = "UPDATE wallet SET wallet='$total' WHERE uid='$uid'";
        }

        if ($conn->query($sql) === TRUE) {
            echo "Wallet updated successfully";
        } else {
            echo "Wallet updating failed: " . $conn->error;
        }

        logWalletInfo($conn, $uid, 0, $lendingAmt, $total, 'N');
}


function logWalletInfo($conn, $uid, $borrowAmt, $lendingAmt, $remainingAmt, $reverse) {
    $sql = "INSERT INTO wallet_log (USER_ID, BORROW_AMT, LENDING_AMT, REVERSE, REMAINING_AMT)
                       VALUES ('$uid', '$borrowAmt','$lendingAmt', '$reverse', '$remainingAmt')";

    $conn->query($sql);

    $conn->close();
}

function updateWalletOnBudgetEnd($uid, $incomeId) {
    $conn = connectToDatabase();

    $sqlMonthly = "SELECT * FROM monthly_expenses WHERE uid = '$uid' AND incomeId = '$incomeId'
                        AND category = 'Daily Expenses'";
    $resultMonthly = $conn->query($sqlMonthly);

    $monthlyAmt = 0;
    $fromDate = '';
    $toDate = '';
    while ($row = $resultMonthly->fetch_assoc()) {
        $monthlyAmt += $row['amount'];
        $fromDate = $row['fromDate'];
        $toDate = $row['toDate'];
    }

    $sqlExpense = "SELECT SUM(amount) AS total_amount
                   FROM daily_expense
                   WHERE uid = '$uid' AND incomeId = '$incomeId'";
    $resultDaily = $conn->query($sqlExpense);

    $dailyAmt = 0;
    if ($resultDaily->num_rows > 0) {
        $row = $resultDaily->fetch_assoc();
        $dailyAmt += $row['total_amount'];
    }

    $sqlWallet = "SELECT * FROM wallet WHERE uid='$uid'";
    $resultWallet = $conn->query($sqlWallet);

    $walletAmt = 0;
    while ($row = $resultWallet->fetch_assoc()) {
        $walletAmt += $row['wallet'];
    }

    $remainingAmt = $monthlyAmt - $dailyAmt;

    if($remainingAmt > 0) {
        $total = $walletAmt + $remainingAmt;

        $sqlUpdate = "UPDATE wallet SET wallet='$total' WHERE uid='$uid'";

        if ($conn->query($sqlUpdate) === TRUE) {
            echo "Wallet updated successfully";
        } else {
            echo "Wallet updating failed: " . $conn->error;
        }
    }

    $conn->close();
}

function getWalletInfo() {
    $conn = connectToDatabase();

    $sqlCheck = "SELECT * FROM wallet";
    $result = $conn->query($sqlCheck);

    $records = array();

    if ($result->num_rows > 0) {
        // Output data of each row
        while ($row = $result->fetch_assoc()) {
            $records[] = $row;
        }
        echo json_encode($records);
    } else {
        echo json_encode(array("message" => "0 results"));
    }

    $conn->close();
}

// Handle OPTIONS request for CORS preflight
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(204);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    getWalletInfo();
} else if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Receive POST data using $_POST
    $response_body = file_get_contents('php://input');
    $data = json_decode($response_body, true);

    $method = $_GET['method'];

    if (!empty($method)) {
        if ($method === "borrow") {
            borrowWalletUpdate($data['uid'], $data['incomeId'], $data['borrowAmt'], $data['reverse']);
        } else if ($method === "lending") {
            lendingWalletUpdate($data['uid'], $data['lendingAmt'], $data['todate']);
        } else if ($method === "updateWallet") {
            updateWalletOnBudgetEnd($data['uid'], $data['incomeId']);
        } else if ($method === "updateBudget") {
            updateWalletBudgetWithBorrow($data['uid'], $data['incomeId']);
        } else {
            http_response_code(400); // Bad request
            echo json_encode(array("error" => "unknown method"));
        }
    } else {
        http_response_code(400); // Bad request
        echo json_encode(array("error" => "Incomplete data received"));
    }
} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(array("error" => "Invalid request method"));
}
?>
