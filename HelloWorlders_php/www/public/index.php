<?php
session_start();
require '../vendor/autoload.php';

use src\Service\MailService;
use Twig\Environment;
use Twig\Loader\FilesystemLoader;

function loadClass($classe)
{
    $ds = DIRECTORY_SEPARATOR;
    $dir = $_SERVER["DOCUMENT_ROOT"] . "$ds..";

    $className = str_replace('\\', $ds, $classe);
    $file = "{$dir}{$ds}{$className}.php";
    if (is_readable($file)) require_once $file;
}

spl_autoload_register('loadClass');

$loader = new FilesystemLoader($_SERVER['DOCUMENT_ROOT'] . '/../src/View');
$twig = new Environment($loader, [
    'cache' => $_SERVER['DOCUMENT_ROOT'] . '/../var/cache',
    'debug' => true,
]);
$mailService = new MailService();

$urls = explode('/', $_GET['url']);
$controllerName = (isset($urls[0])) ? $urls[0] : '';
$action = (isset($urls[1])) ? $urls[1] : '';
$param = (isset($urls[2])) ? $urls[2] : '';

if ($controllerName != '') {
    try {
        $class = "src\Controller\\{$controllerName}Controller";
        if (class_exists($class)) {
            $controller = new $class();
            if (method_exists($controller, $action)) {
                if ($action === 'add') {
                    echo $controller->$action($mailService, $twig);
                } else {
                    echo $controller->$action($param);
                }
            } else {
                throw new \Exception("Action {$action} does not exist in controller {$class}");
            }
        } else {
            throw new \Exception("Controller {$controllerName} does not exist");
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