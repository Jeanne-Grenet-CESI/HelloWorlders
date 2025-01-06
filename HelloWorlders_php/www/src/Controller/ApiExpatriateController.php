<?php

namespace src\Controller;

use src\Model\Expatriate;
use src\Service\JwtService;

class ApiExpatriateController {

    public function __construct()
    {
        // Définit le type de contenu pour toutes les réponses JSON
        header('Content-Type: application/json; charset=utf-8');
    }

    public function getAll()
    {

        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            header('HTTP/1.1 405 Method Not Allowed');
            return json_encode(["status" => "error", "message" => "Méthode non autorisée, GET attendu"]);
        }

        $expatriates = Expatriate::SqlGetAll();
        return json_encode($expatriates);
    }

    public function add()
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            header('HTTP/1.1 405 Method Not Allowed');
            return json_encode(["status" => "error", "message" => "Méthode non autorisée, POST attendu"]);
        }

        $jwtresult = JwtService::checkToken();
        if ($jwtresult["status"] === "error") {
            return json_encode($jwtresult["message"]);
        }
            //Récupération du body en JSON
        $data = file_get_contents('php://input');
        $json = json_decode($data);

        if (empty($json)) {
            header('HTTP/1.1 400 Bad Request');
            return json_encode(["status" => "error", "message" => "Aucune données reçues"]);
        }

        $sqlRepository = null;
        $imageName = null;
        if(isset($json->Image)){
            $imageName = uniqid().".jpg";
            //Fabrication du répertoire d'accueil
            $dateNow = new \DateTime();
            $sqlRepository = $dateNow->format('Y/m');
            $repository = './uploads/images/' . $dateNow->format('Y/m');
            if (!is_dir($repository)) {
                mkdir($repository, 0777, true);
            }
            //Fabrication de l'image
            $ifp = fopen($repository . '/' . $imageName, "wb");
            fwrite($ifp, base64_decode($json->Image));
            fclose($ifp);
        }

        $country = ExpatriateController::calculCountry($json->Latitude, $json->Longitude);
        $username = $jwtresult["data"]->Username;

        $expatriate = new Expatriate();
        $expatriate->setFirstname( $json->Firstname)
            ->setLastname($json->Lastname)
            ->setEmail($json->Email)
            ->setArrivalDate(new \DateTime($json->ArrivalDate))
            ->setDepartureDate(new \DateTime($json->DepartureDate))
            ->setLatitude($json->Latitude)
            ->setLongitude($json->Longitude)
            ->setCountry($country)
            ->setImageRepository($sqlRepository)
            ->setImageFileName($imageName)
            ->setAge($json->Age)
            ->setUsername($username)
            ->setDescription($json->Description)
            ->setGender($json->Gender);

        $result = Expatriate::SqlAdd($expatriate);
        return json_encode(["status" => "success", "message" => "Profil créé avec success", "id" => $result]);
    }

    public function getById($id)
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            header('HTTP/1.1 405 Method Not Allowed');
            return json_encode(["status" => "error", "message" => "Méthode non autorisée, GET attendu"]);
        }

        $expatriate = Expatriate::SqlGetById($id);
        return json_encode($expatriate);

    }

}
