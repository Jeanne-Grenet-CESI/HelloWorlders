<?php
session_start();
require '../vendor/autoload.php';
function loadClass($classe)
{
    $ds = DIRECTORY_SEPARATOR;
    $dir = $_SERVER["DOCUMENT_ROOT"] . "$ds..";

    $className = str_replace('\\', $ds, $classe);
    $file = "{$dir}{$ds}{$className}.php";
    if (is_readable($file)) require_once $file;
}

spl_autoload_register('loadClass');

$urls = explode('/', $_GET['url']);
$controller = (isset($urls[0])) ? $urls[0] : '';
$action = (isset($urls[1])) ? $urls[1] : '';
$param = (isset($urls[2])) ? $urls[2] : '';

if($controller != ''){
    try {
        $class = "src\Controller\\{$controller}Controller";
        if (class_exists($class)) {
            $controller = new $class();
            if (method_exists($controller, $action)) {
                echo $controller->$action($param);
            } else {
                throw new \Exception("Action {$action} does not exist in controller {$class}");
            }
        } else {
            throw new \Exception("Controller {$controller} does not exist");
        }
    }catch (\Exception $e){
//        $controller = new \src\Controller\ErrorController();
//        echo $controller->error($e->getMessage());
        //TODO : Implement later
    }
}else {
    $controller = new \src\Controller\ExpatriateController();
    $action = $controller->index();
    echo $action;
}