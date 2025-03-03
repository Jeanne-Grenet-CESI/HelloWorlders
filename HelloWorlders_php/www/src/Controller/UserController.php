<?php

namespace src\Controller;

use Src\Model\Expatriate;
use Src\Model\User;
use src\Service\JwtService;

class UserController extends AbstractController
{
    public function create()
    {
        if (isset($_POST["mail"]) && isset($_POST["password"]) && isset($_POST["username"])) {
            if (!$this->isValidCsrfToken()) {
                throw new \Exception("Invalid CSRF token");
            }

            $user = new User();
            $hashpass = password_hash($_POST["password"], PASSWORD_BCRYPT, ["cost" => 12]);

            $user->setEmail($_POST["mail"])
                ->setPassword($hashpass)
                ->setUsername($_POST["username"])
                ->setIsAdmin(false); // Toujours false par défaut

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

    public static function apiIsConnected()
    {
        $jwtresult = JwtService::checkToken();
        if($jwtresult["status"] === "success") {
            return json_encode(["status" => "success", "message" => "Utilisateur connecté"]);
        } else {
            header('HTTP/1.1 401 Unauthorized');
            return json_encode(["status" => "error", "message" => "Utilisateur non connecté"]);
        }
    }

    public static function isAdmin()
    {
        if (!isset($_SESSION["login"]) || !$_SESSION["login"]["IsAdmin"]) {
            throw new \Exception("Vous n'êtes pas autorisé à accéder à cette page ou cette fonctionnalité");
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

            if (!$this->isValidCsrfToken()) {
                throw new \Exception("Invalid CSRF token");
            }

            $user = User::SqlGetByMail($_POST["mail"]);
            if ($user != null) {
                if (password_verify($_POST["password"], $user->getPassword())) {
                    session_regenerate_id(true);

                    $_SESSION["login"] = [
                        "Email" => $user->getEmail(),
                        "Username" => $user->getUsername(),
                        "IsAdmin" => $user->getIsAdmin()
                    ];

                    $this->csrfTokenService->refreshToken();

                    header("Location: /");
                } else {
                    throw new \Exception("Mot de passe incorrect pour {$_POST["mail"]}");
                }
            } else {
                throw new \Exception("Aucun user avec ce mail en base");
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
        if ($user === null) {
            header('HTTP/1.1 403 Forbiden');
            return json_encode(["status" => "error", "message" => "Utilisateur inconnu"]);
        }
        if (!password_verify($json->Password, $user->getPassword())) {
            header('HTTP/1.1 403 Forbiden');
            return json_encode(["status" => "error", "message" => "Mot de passe incorrect"]);
        }
        return JwtService::createToken([
            "Email" => $user->getEmail(),
            "Username" => $user->getUsername()
        ]);
    }

    public function register()
    {
        header('Content-Type: application/json; charset=utf-8');

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            header('HTTP/1.1 405 Method Not Allowed');
            echo json_encode(["status" => "error", "message" => "Méthode non autorisée, POST attendu"]);
            exit();
        }

        $data = file_get_contents('php://input');
        $json = json_decode($data, true);

        if (empty($json)) {
            header('HTTP/1.1 400 Bad Request');
            echo json_encode(["status" => "error", "message" => "Aucune donnée reçue"]);
            exit();
        }

        if (!isset($json["Username"]) || !isset($json["Email"]) || !isset($json["Password"])) {
            header('HTTP/1.1 400 Bad Request');
            echo json_encode(["status" => "error", "message" => "Données manquantes"]);
            exit();
        }

        if (User::SqlGetByMail($json["Email"]) !== null) {
            header('HTTP/1.1 409 Conflict');
            echo json_encode(["status" => "error", "message" => "Cet email est déjà utilisé"]);
            exit();
        }

        $user = new User();
        $hashpass = password_hash($json["Password"], PASSWORD_BCRYPT, ["cost" => 12]);

        $user->setUsername($json["Username"])
            ->setEmail($json["Email"])
            ->setPassword($hashpass)
            ->setIsAdmin(false);

        $id = User::SqlAdd($user);

        if ($id) {
            echo json_encode(["status" => "success", "message" => "Inscription réussie"]);
        } else {
            header('HTTP/1.1 500 Internal Server Error');
            echo json_encode(["status" => "error", "message" => "Erreur lors de l'inscription"]);
        }
        exit();
    }

    public function account()
    {
        self::isConnected();
        $user = User::SqlGetByMail($_SESSION["login"]["Email"]);
        $expatriates = Expatriate::SqlGetByUser($user->getUsername());
        return $this->twig->render("User/account.html.twig", ['expatriates' => $expatriates, 'user' => $user]);
    }

    public function apiAccount()
    {
        ini_set('display_errors', 0);

        header('Content-Type: application/json; charset=utf-8');

        try {
            $result = JwtService::checkToken();

            if ($result['status'] !== 'success') {
                http_response_code(401);
                echo json_encode(['message' => 'Token invalide']);
                exit;
            }

            $user = User::SqlGetByMail($result['data']->Email);
            $expatriates = Expatriate::SqlGetByUser($user->getUsername());

            $userData = [
                'id' => $user->getId(),
                'username' => $user->getUsername(),
                'email' => $user->getEmail(),
                'isAdmin' => $user->getIsAdmin()
            ];

            $expatriatesData = [];
            foreach ($expatriates as $expatriate) {
                $arrivalDate = $expatriate->getArrivalDate();
                $departureDate = $expatriate->getDepartureDate();

                $expatriateData = [
                    'Id' => $expatriate->getId() ?? 0,
                    'Firstname' => $expatriate->getFirstname() ?? '',
                    'Lastname' => $expatriate->getLastname() ?? '',
                    'Email' => $expatriate->getEmail() ?? '',
                    'ArrivalDate' => $arrivalDate ? $arrivalDate->format('Y-m-d') : date('Y-m-d'),
                    'DepartureDate' => $departureDate ? $departureDate->format('Y-m-d') : null,
                    'Latitude' => $expatriate->getLatitude() ?? 0.0,
                    'Longitude' => $expatriate->getLongitude() ?? 0.0,
                    'Country' => $expatriate->getCountry() ?? '',
                    'ImageRepository' => $expatriate->getImageRepository(),
                    'ImageFileName' => $expatriate->getImageFileName(),
                    'Gender' => $expatriate->getGender(),
                    'Age' => $expatriate->getAge() ?? 0,
                    'Username' => $expatriate->getUsername() ?? '',
                    'Description' => $expatriate->getDescription()
                ];

                $expatriatesData[] = $expatriateData;
            }

            echo json_encode([
                'user' => $userData,
                'expatriates' => $expatriatesData
            ]);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['message' => 'Erreur: ' . $e->getMessage()]);
        }
        exit;
    }
}