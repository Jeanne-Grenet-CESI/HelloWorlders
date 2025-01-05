<?php

namespace src\Controller;

use src\Model\Expatriate;

class ExpatriateController extends AbstractController
{
    public function index()
    {
        $expatriates = Expatriate::SqlGetAll();
        return $this->twig->render('expatriate/index.html.twig',['expatriates' => $expatriates]);
    }

    public function add()
    {
        UserController::isConnected();
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $country = $this->calculCountry($_POST['Latitude'], $_POST['Longitude']);
            try {

                $sqlRepository = null;
                $imageName = null;
                if (!empty($_FILES['Image']['name'])) {
                    $tabExt = ['jpg', 'gif', 'png', 'jpeg'];
                    $extension = pathinfo($_FILES['Image']['name'], PATHINFO_EXTENSION);
                    if (in_array(strtolower($extension), $tabExt)) {
                        $dateNow = new \DateTime();
                        $sqlRepository = $dateNow->format('Y/m');
                        $repository = './uploads/images/' . $dateNow->format('Y/m');
                        if (!is_dir($repository)) {
                            mkdir($repository, 0777, true);
                        }
                        $imageName = md5(uniqid()) . '.' . $extension;


                        move_uploaded_file($_FILES['Image']['tmp_name'], $repository . '/' . $imageName);
                    }
                }

                // Créer un objet Expatriate et le remplir
                $expatriate = new Expatriate();
                $expatriate->setFirstname( $_POST['Firstname'])
                    ->setLastname($_POST['Lastname'])
                    ->setEmail($_POST['Email'])
                    ->setArrivalDate(new \DateTime($_POST['ArrivalDate'] ))
                    ->setDepartureDate(new \DateTime($_POST['DepartureDate'] ))
                    ->setLatitude($_POST['Latitude'])
                    ->setLongitude($_POST['Longitude'])
                    ->setCountry($country)
                    ->setImageRepository( $sqlRepository)
                    ->setImageFileName($imageName)
                    ->setAge($_POST['Age'])
                    ->setUsername($_SESSION['login']['Username'])
                    ->setDescription($_POST['Description'])
                    ->setGender($_POST['Gender']);

                $result = Expatriate::SqlAdd($expatriate);
                
                if ($result) {
                    header('Location: /');
                    exit;
                } else {
                    throw new \Exception("Erreur lors de l'ajout de l'expatrié.");
                }
            } catch (\Exception $e) {
                echo "Erreur : " . $e->getMessage();
            }
        } else {
            return $this->twig->render('Expatriate/add.html.twig');
        }
    }

    public function update($id)
    {
        UserController::isConnected();
        $expatriate = Expatriate::SqlGetById($id);
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $country = $this->calculCountry($_POST['Latitude'], $_POST['Longitude']);
            try {
                // Créer un objet Expatriate et le remplir
                $expatriate = new Expatriate();
                $expatriate->setFirstname( $_POST['Firstname'] ?? null)
                    ->setLastname($_POST['Lastname'] ?? null)
                    ->setEmail($_POST['Email'] ?? null)
                    ->setArrivalDate(new \DateTime($_POST['ArrivalDate'] ?? null))
                    ->setDepartureDate(new \DateTime($_POST['DepartureDate'] ?? null))
                    ->setLatitude($_POST['Latitude'] ?? null)
                    ->setLongitude($_POST['Longitude'] ?? null)
                    ->setCountry($country)
                    ->setImageRepository( $_POST['ImageRepository'] ?? null)
                    ->setImageFileName($_POST['ImageFileName'] ?? null)
                    ->setAge($_POST['Age'] ?? null)
                    ->setUsername($_SESSION['login']['Username'])
                    ->setDescription($_POST['Description'] ?? null)
                    ->setGender($_POST['Gender'] ?? null);

                $result = Expatriate::SqlAdd($expatriate);

                if ($result) {
                    header('Location: /');
                    exit;
                } else {
                    throw new \Exception("Erreur lors de l'ajout de l'expatrié.");
                }
            } catch (\Exception $e) {
                echo "Erreur : " . $e->getMessage();
            }
        } else {
            return $this->twig->render('Expatriate/add.html.twig');
        }
    }

    function details(int $id)
    {
        $expatriate = Expatriate::SqlGetById($id);
        return $this->twig->render('Expatriate/details.html.twig', ['expatriate' => $expatriate]);
    }



    function calculCountry(float $latitude, float $longitude): ?string
    {
        // URL de l'API Nominatim
        $url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&accept-language=fr";

        // Initialiser une session cURL
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_USERAGENT, 'HelloWorlders/1.0'); // Fournissez un User-Agent valide

        // Exécuter la requête
        $response = curl_exec($curl);
        curl_close($curl);

        // Vérifier si la réponse est valide
        if ($response) {
            $data = json_decode($response, true);
            if (isset($data['address']['country'])) {
                return $data['address']['country']; // Retourne le nom du pays
            }
        }

        return null; // Retourne null si le pays n'a pas pu être déterminé
    }

}