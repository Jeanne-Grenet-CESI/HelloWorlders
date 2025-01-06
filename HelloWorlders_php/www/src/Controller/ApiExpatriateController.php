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
    public function update($id)
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
            header('HTTP/1.1 405 Method Not Allowed');
            return json_encode(["status" => "error", "message" => "Méthode non autorisée, PUT attendu"]);
        }

        $jwtresult = JwtService::checkToken();
        if ($jwtresult["status"] === "error") {
            return json_encode($jwtresult["message"]);
        }

        $data = file_get_contents('php://input');
        $json = json_decode($data);

        if (empty($json)) {
            header('HTTP/1.1 400 Bad Request');
            return json_encode(["status" => "error", "message" => "Aucune donnée reçue"]);
        }

        $expatriate = Expatriate::SqlGetById($id);
        if (!$expatriate) {
            header('HTTP/1.1 404 Not Found');
            return json_encode(["status" => "error", "message" => "Expatrié introuvable"]);
        }

        $username = $jwtresult["data"]->Username;
        if ($expatriate->getUsername() !== $username) {
            header('HTTP/1.1 403 Forbidden');
            return json_encode(["status" => "error", "message" => "Vous n'êtes pas autorisé à modifier cet expatrié."]);
        }

        $sqlRepository = $expatriate->getImageRepository();
        $imageName = $expatriate->getImageFileName();

        if (isset($json->Image) && !empty($json->Image)) {
            $dateNow = new \DateTime();
            $sqlRepository = $dateNow->format('Y/m');
            $repository = './uploads/images/' . $sqlRepository;
            if (!is_dir($repository)) {
                mkdir($repository, 0777, true);
            }

            $imageName = uniqid() . ".jpg";

            // Sauvegarde de la nouvelle image
            $ifp = fopen($repository . '/' . $imageName, "wb");
            fwrite($ifp, base64_decode($json->Image));
            fclose($ifp);

            // Suppression de l'ancienne image
            $oldImagePath = "./uploads/images/{$expatriate->getImageRepository()}/{$expatriate->getImageFileName()}";
            if (file_exists($oldImagePath)) {
                unlink($oldImagePath);
            }
        }

        $country = ($json->Latitude != $expatriate->getLatitude() || $json->Longitude != $expatriate->getLongitude())
            ? ExpatriateController::calculCountry($json->Latitude, $json->Longitude)
            : $expatriate->getCountry();

        $expatriate->setFirstname($json->Firstname ?? $expatriate->getFirstname())
            ->setLastname($json->Lastname ?? $expatriate->getLastname())
            ->setEmail($json->Email ?? $expatriate->getEmail())
            ->setArrivalDate(new \DateTime($json->ArrivalDate ?? $expatriate->getArrivalDate()->format('Y-m-d')))
            ->setDepartureDate(new \DateTime($json->DepartureDate ?? $expatriate->getDepartureDate()->format('Y-m-d')))
            ->setLatitude($json->Latitude ?? $expatriate->getLatitude())
            ->setLongitude($json->Longitude ?? $expatriate->getLongitude())
            ->setCountry($country)
            ->setImageRepository($sqlRepository)
            ->setImageFileName($imageName)
            ->setAge($json->Age ?? $expatriate->getAge())
            ->setDescription($json->Description ?? $expatriate->getDescription())
            ->setGender($json->Gender ?? $expatriate->getGender())
            ->setUsername($expatriate->getUsername());

            $result = Expatriate::SqlUpdate($expatriate);

        if ($result) {
            return json_encode(["status" => "success", "message" => "Profil mis à jour avec succès"]);
        } else {
            header('HTTP/1.1 500 Internal Server Error');
            return json_encode(["status" => "error", "message" => "Aucune mise à jour effectuée"]);
        }
    }

    public function delete($id)
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
            header('HTTP/1.1 405 Method Not Allowed');
            return json_encode(["status" => "error", "message" => "Méthode non autorisée, DELETE attendu"]);
        }

        $jwtresult = JwtService::checkToken();
        if ($jwtresult["status"] === "error") {
            return json_encode($jwtresult["message"]);
        }

        $expatriate = Expatriate::SqlGetById($id);
        if (!$expatriate) {
            header('HTTP/1.1 404 Not Found');
            return json_encode(["status" => "error", "message" => "Expatrié introuvable"]);
        }

        $username = $jwtresult["data"]->Username;
        if ($expatriate->getUsername() !== $username) {
            header('HTTP/1.1 403 Forbidden');
            return json_encode(["status" => "error", "message" => "Vous n'êtes pas autorisé à supprimer cet expatrié."]);
        }

        $result = Expatriate::SqlDelete($id);
        if ($result) {
            return json_encode(["status" => "success", "message" => "Profil supprimé avec succès"]);
        } else {
            header('HTTP/1.1 500 Internal Server Error');
            return json_encode(["status" => "error", "message" => "Aucune suppression effectuée"]);
        }
    }

}
