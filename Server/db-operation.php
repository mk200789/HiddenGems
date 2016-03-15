<?php
 
require 'vendor/autoload.php';
require 'database/conn.php';
 
$app = new Slim\App();
 
$app->get('/', 'get_users');
 
$app->run();
 
function get_users() {
    $db = connect_db();
    $sql = "SELECT * FROM user";
    $exe = $db->query($sql);
    $data = $exe->fetch_all(MYSQLI_ASSOC);
    $db = null;
    echo json_encode($data);
}
 
?>
