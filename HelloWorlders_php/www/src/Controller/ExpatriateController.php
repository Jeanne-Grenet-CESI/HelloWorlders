<?php

namespace src\Controller;

use Mpdf\Mpdf;
use Mpdf\Output\Destination;
use src\Model\BDD;
use src\Model\Expatriate;
use src\Service\MailService;
use Twig\Environment;

class ExpatriateController extends AbstractController
{
    public function index()
    {
        $expatriates = Expatriate::SqlGetAll();
        return $this->twig->render('expatriate/index.html.twig', ['expatriates' => $expatriates]);
    }

    public function add(MailService $mailService, Environment $twig)
    {
        UserController::isConnected();
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                if (!$this->isValidCsrfToken()) {
                    throw new \Exception("Invalid CSRF token");
                }

                $country = $this->calculCountry($_POST['Latitude'], $_POST['Longitude']);
                $departureDate = !empty($_POST['DepartureDate']) ? new \DateTime($_POST['DepartureDate']) : null;

                $sqlRepository = null;
                $imageName = null;
                if (!empty($_FILES['Image']['name'])) {
                    $allowedExtensions = ['jpg', 'gif', 'png', 'jpeg'];
                    $extension = pathinfo($_FILES['Image']['name'], PATHINFO_EXTENSION);
                    if (in_array(strtolower($extension), $allowedExtensions)) {
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

                $expatriate = new Expatriate();
                $expatriate->setFirstname($_POST['Firstname'])
                    ->setLastname($_POST['Lastname'])
                    ->setEmail($_POST['Email'])
                    ->setArrivalDate(new \DateTime($_POST['ArrivalDate']))
                    ->setDepartureDate($departureDate)
                    ->setLatitude($_POST['Latitude'])
                    ->setLongitude($_POST['Longitude'])
                    ->setCountry($country)
                    ->setImageRepository($sqlRepository)
                    ->setImageFileName($imageName)
                    ->setAge($_POST['Age'])
                    ->setUsername($_SESSION['login']['Username'])
                    ->setDescription($_POST['Description'])
                    ->setGender($_POST['Gender']);

                $insertedId = Expatriate::SqlAdd($expatriate);
                $expatriate->setId($insertedId);
                if ($insertedId) {
                    $emailContent = $twig->render('email/confirmation.html.twig', [
                        'expatriate' => $expatriate,
                        'detailsUrl' => "http://www.helloworlders.local/Expatriate/details/" . $expatriate->getId(),
                    ]);
                    $mailService->send(
                        'noreply@helloworlders.local',
                        $expatriate->getEmail(),
                        'Confirmation de votre enregistrement',
                        $emailContent
                    );

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

        if ($expatriate->getUsername() !== $_SESSION['login']['Username'] && !$_SESSION['login']['IsAdmin']) {
            throw new \Exception("Vous n'êtes pas autorisé à modifier cet expatrié.");
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                if (!$this->isValidCsrfToken()) {
                    throw new \Exception("Invalid CSRF token");
                }

                $sqlRepository = $expatriate->getImageRepository();
                $nomImage = $expatriate->getImageFileName();

                if (isset($_FILES["Image"]["name"]) && $_FILES["Image"]["name"] !== '') {
                    $extensionsAutorisees = ["jpg", "jpeg", "png"];
                    $extension = pathinfo($_FILES["Image"]["name"], PATHINFO_EXTENSION);

                    if (in_array(strtolower($extension), $extensionsAutorisees)) {
                        $dateNow = new \DateTime();
                        $sqlRepository = $dateNow->format("Y/m");
                        $repository = "./uploads/images/{$sqlRepository}";

                        if (!is_dir($repository)) {
                            mkdir($repository, 0777, true);
                        }

                        $nomImage = uniqid() . "." . $extension;

                        move_uploaded_file($_FILES["Image"]["tmp_name"], $repository . "/" . $nomImage);

                        $this->deleteImage($expatriate->getImageRepository(), $expatriate->getImageFileName());
                    }
                }

                if ($_POST['Latitude'] != $expatriate->getLatitude() || $_POST['Longitude'] != $expatriate->getLongitude()) {
                    $country = $this->calculCountry($_POST['Latitude'], $_POST['Longitude']);
                } else {
                    $country = $expatriate->getCountry();
                }

                $expatriate->setFirstname($_POST['Firstname'] ?? $expatriate->getFirstname())
                    ->setLastname($_POST['Lastname'] ?? $expatriate->getLastname())
                    ->setEmail($_POST['Email'] ?? $expatriate->getEmail())
                    ->setArrivalDate(new \DateTime($_POST['ArrivalDate'] ?? $expatriate->getArrivalDate()->format('Y-m-d')))
                    ->setDepartureDate(new \DateTime($_POST['DepartureDate'] ?? $expatriate->getDepartureDate()->format('Y-m-d')))
                    ->setLatitude($_POST['Latitude'] ?? $expatriate->getLatitude())
                    ->setLongitude($_POST['Longitude'] ?? $expatriate->getLongitude())
                    ->setCountry($country)
                    ->setImageRepository($sqlRepository)
                    ->setImageFileName($nomImage)
                    ->setAge($_POST['Age'] ?? $expatriate->getAge())
                    ->setUsername($expatriate->getUsername()) // Conserver le username existant
                    ->setDescription($_POST['Description'] ?? $expatriate->getDescription())
                    ->setGender($_POST['Gender'] ?? $expatriate->getGender());

                Expatriate::SqlUpdate($expatriate);

                header('Location: /');
                exit;
            } catch (\Exception $e) {
                echo "Erreur : " . $e->getMessage();
            }
        }
        return $this->twig->render('Expatriate/update.html.twig', ['expatriate' => $expatriate]);
    }

    function details(int $id)
    {
        $expatriate = Expatriate::SqlGetById($id);
        return $this->twig->render('Expatriate/details.html.twig', ['expatriate' => $expatriate]);
    }

    public function delete(int $id)
    {
        UserController::isConnected();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            if (!$this->isValidCsrfToken()) {
                throw new \Exception("Invalid CSRF token");
            }
        }

        $expatriate = Expatriate::SqlGetById($id);

        if ($expatriate->getUsername() !== $_SESSION['login']['Username'] && !$_SESSION['login']['IsAdmin']) {
            throw new \Exception("Vous n'êtes pas autorisé à supprimer cet expatrié.");
        }

        $this->deleteImage($expatriate->getImageRepository(), $expatriate->getImageFileName());

        Expatriate::SqlDelete($id);
        header('Location: /');
        exit;
    }

    private function deleteImage(string|null $repository, string|null $fileName): void
    {
        $imagePath = "{$_SERVER["DOCUMENT_ROOT"]}/uploads/images/{$repository}/{$fileName}";
        if (!empty($fileName) && file_exists($imagePath)) {
            unlink($imagePath);
        }
    }

    static function calculCountry(float $latitude, float $longitude): ?string
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

    public function pdf(int $id)
    {
        $expatriate = Expatriate::SqlGetById($id);

        $fileName = $expatriate->getFirstname() . '_' . $expatriate->getLastname() . '.pdf';

        $mpdf = new Mpdf([
            "tempDir" => $_SERVER['DOCUMENT_ROOT'] . "/../var/cache/expatriate/" . $expatriate->getId() . '/pdf'
        ]);
        $mpdf->WriteHTML($this->twig->render('Expatriate/pdf.html.twig', ['expatriate' => $expatriate]));
        $mpdf->Output($fileName, \Mpdf\Output\Destination::DOWNLOAD);
    }

    public function fixtures()
    {
        UserController::isAdmin();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            if (!$this->isValidCsrfToken()) {
                throw new \Exception("Invalid CSRF token");
            }
        }

        $requete = BDD::getInstance()->prepare("TRUNCATE TABLE expatriate");
        $requete->execute();
        $firstnameArray = ["Jeanne", "Arthur", "Nico", "Antoine", "Laura"];
        $lastnameArray = ["Dupont", "Durand", "Martin", "Bernard", "Lefevre"];
        $emailArray = ["j@j.fr", "a@a.fr", "n@n.fr", "l@l.fr"];
        $date = date('Y-m-d H:i:s');
        for ($i = 0; $i < 200; $i++) {
            $firstname = $firstnameArray[rand(0, 4)];
            $lastname = $lastnameArray[rand(0, 4)];
            $email = $emailArray[rand(0, 3)];
            $date = date('Y-m-d H:i:s', strtotime($date . " + 1 days"));
            $expatriate = new Expatriate();
            $expatriate->setFirstname($firstname)
                ->setLastname($lastname)
                ->setEmail($email)
                ->setArrivalDate(new \DateTime($date))
                ->setLatitude(rand(-90, 90))
                ->setLongitude(rand(-180, 180))
                ->setCountry("France")
                ->setImageRepository(null)
                ->setImageFileName(null)
                ->setAge(rand(18, 99))
                ->setUsername("admin")
                ->setDescription("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam maximus maximus ex, et venenatis ligula viverra ut. Donec commodo, eros semper efficitur facilisis");
            Expatriate::SqlAdd($expatriate);
        }
        header('Location: /');
    }
}