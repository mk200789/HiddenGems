<?php
require_once ("Rest.php");
require_once ("config.php");

class API extends REST{
    private $db= NULL;
 
    // Constructor - open DB connection
    public function __construct() {
        parent::__construct();
        $this->db = new mysqli(db_host ,db_username, db_password, db_database);
        //$this->db->autocommit(FALSE);

        if ($this->db->connect_error) {
            die("Connection failed: " . $this->db->connect_error);
        } 
        //echo "Connected successfully";

    }
 
    // Destructor - close DB connection
    public function __destruct() {
        $this->db->close();
    }
 

    public function processApi() {
        $func = strtolower(trim(str_replace("/", "", $_REQUEST['request'])));
        if ((int)method_exists($this, $func) > 0) {
            $this->$func();
        } else {
            $this->response('', 404);
        }
        // If the method not exist with in this class, response would be "Page not found".
    }

    // Main method to redeem a code
    function users() {
        // Print all codes in database
        $stmt = $this->db->prepare("SELECT * FROM user");
        $stmt->execute();
        $stmt->bind_result($username, $email, $password);
        while ($stmt->fetch()) {
            echo "$username has $email and $password!";
        }
        $stmt->close();
    }


    function createuser(){

        // Cross validation if the request method is POST else it will return "Not Acceptable" status
        if ($this->get_request_method() != "POST") {
            $this->response('Incorrect Request Method', 406);
        }

         if ($_POST == null) {
            $handle = fopen('php://input', 'r');
            $rawData = fgets($handle);
            $body = json_decode($rawData, true);
        } else {
            $body = $_POST;
        }

        //echo 'Invalid request'.$body['username'].'-'.$body['password'].'-'.$body['email'];

        if (isset($body['username']) && isset($body['password']) && isset($body['email'])) {
 
            // Put parameters into local variables
            $username = $body['username'];
            $password = $body['password'];
            $email = $body['email'];

            $stmt = $this->db->prepare("INSERT INTO user (username, password, email) VALUES (?, ?, ?)");
            $stmt->bind_param("sss", $username, $password, $email);
            $stmt->execute();
            $stmt->close();

            $result = array(
                "message" => "Added user",
            );
            
            $this->response($this->json($results), 200);
            return true;
        }

        $this->response('Invalid request', 400);
        return false;
    }
 

    private function json($data) {
        if (is_array($data)) {
            return json_encode($data);
        }
    }
}

// This is the first thing that gets called when this page is loaded
// Creates a new instance of the RedeemAPI class and calls the redeem method
$api = new API;
$api->processApi();
 


?>


