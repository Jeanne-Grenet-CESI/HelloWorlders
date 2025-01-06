<?php

namespace src\Controller;

use Src\Model\User;
use src\Service\JwtService;

class UserController extends AbstractController
{
    public function create()
    {
        if (isset($_POST["mail"]) && isset($_POST["password"])) {
            $user = new User();
            $hashpass = password_hash($_POST["password"], PASSWORD_BCRYPT, ["cost" => 12]);
            $user->setEmail($_POST["mail"])
                ->setPassword($hashpass)
                ->setUsername($_POST["username"]);
            $id = User::SqlAdd($user);
            header("Location:/User/login");
            exit();
        } else {
            return $this->twig->render("User/create.html.twig");
        }
    }

    public static function isConnected()
    {
        if (!isset($_SESSION["login"])) {
            header("Location:/User/login");
        }
    }

    public function logout()
    {
        unset($_SESSION["login"]);
        header("Location:/");
    }

    public function login()
    {
        if (isset($_POST["mail"]) && isset($_POST["password"])) {
            $user = User::SqlGetByMail($_POST["mail"]);
            if ($user != null) {

                if (password_verify($_POST["password"], $user->getPassword())) {


                    $_SESSION["login"] = [
                        "Email" => $user->getEmail(),
                        "Username" => $user->getUsername(),
                    ];

                    header("Location: /");
                } else {
                    throw new \Exception("Incorect password for {$_POST["mail"]}");
                }
            } else {
                throw new \Exception("No user with this mail in database");
            }
        } else {
            return $this->twig->render("User/login.html.twig");
        }
    }

    public function loginjwt()
    {
        header('Content-Type: application/json ; charset=utf-8');
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            header('HTTP/1.1 405 Method Not Allowed');
            return json_encode(["status" => "error", "message" => "Méthode non autorisée, POST attendu"]);
        }

        //Récupération du body en JSON
        $data = file_get_contents('php://input');
        $json = json_decode($data);

        if (empty($json)) {
            header('HTTP/1.1 400 Bad Request');
            return json_encode(["status" => "error", "message" => "Aucune données reçues"]);
        }

        if (!isset($json->Email) || !isset($json->Password)) {
            header('HTTP/1.1 400 Bad Request');
            return json_encode(["status" => "error", "message" => "Données manquantes"]);
        }

        $user = User::SqlGetByMail($json->Email);
        if($user === null){
            header('HTTP/1.1 403 Forbiden');
            return json_encode(["status" => "error", "message" => "Utilisateur inconnu"]);
        }
        if(!password_verify($json->Password, $user->getPassword())){
            header('HTTP/1.1 403 Forbiden');
            return json_encode(["status" => "error", "message" => "Mot de passe incorrect"]);
        }
        return JwtService::createToken([
            "Email" => $user->getEmail(),
            "Username" => $user->getUsername()
        ]);
    }

}