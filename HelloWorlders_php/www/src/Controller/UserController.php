<?php

namespace src\Controller;

use Src\Model\User;
use src\Service\JwtService;

class UserController extends AbstractController
{
    public function create(){
        if(isset($_POST["mail"]) && isset($_POST["password"])){
            $user = new User();
            $hashpass = password_hash($_POST["password"], PASSWORD_BCRYPT, ["cost"=>12]);
            $user->setEmail($_POST["mail"])
                ->setPassword($hashpass);
            $id = User::SqlAdd($user);
            header("Location:/User/login");
            exit();
        }else{
            return $this->twig->render("User/create.html.twig");
        }
    }

    public static function isConnected() {
        if(!isset($_SESSION["login"])){
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
        if(isset($_POST["mail"]) && isset($_POST["password"])){
            $user = User::SqlGetByMail($_POST["mail"]);
            if($user!=null){

                if(password_verify($_POST["password"], $user->getPassword())){


                    $_SESSION["login"] = [
                        "Email" => $user->getEmail(),

                    ];

                    header("Location: /");
                }else{
                    throw new \Exception("Incorect password for {$_POST["mail"]}");
                }
            }else{
                throw new \Exception("No user with this mail in database");
            }
        }else{
            return $this->twig->render("User/login.html.twig");
        }
    }

}