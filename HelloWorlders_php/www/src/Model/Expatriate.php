<?php

namespace Src\Model;
class Expatriate  implements \JsonSerializable
{
    private ?int $Id = null;
    private ?string $FirstName = null;
    private ?string $LastName = null;
    private ?string $Email = null;
    private ?\DateTime $ArrivalDate = null;
    private ?\DateTime $DepartureDate = null;
    private ?float $Latitude = null;
    private ?float $Longitude = null;
    private ?string $Country = null;
    private ?string $ImageRepository = null;
    private ?string $ImageFileName = null;
    private ?string $Gender = null;
    private ?int $Age = null;
    private ?string $Username = null;
    private ?string $Description = null;

    public function getId(): ?int
    {
        return $this->Id;
    }

    public function setId(?int $Id): Expatriate
    {
        $this->Id = $Id;
        return $this;
    }

    public function getFirstname(): ?string
    {
        return $this->FirstName;
    }

    public function setFirstname(?string $FirstName): Expatriate
    {
        $this->FirstName = $FirstName;
        return $this;
    }

    public function getLastname(): ?string
    {
        return $this->LastName;
    }

    public function setLastname(?string $LastName): Expatriate
    {
        $this->LastName = $LastName;
        return $this;
    }

    public function getEmail(): ?string
    {
        return $this->Email;
    }

    public function setEmail(?string $Email): Expatriate
    {
        $this->Email = $Email;
        return $this;
    }

    public function getArrivalDate(): ?\DateTime
    {
        return $this->ArrivalDate;
    }

    public function setArrivalDate(?\DateTime $ArrivalDate): Expatriate
    {
        $this->ArrivalDate = $ArrivalDate;
        return $this;
    }

    public function getDepartureDate(): ?\DateTime
    {
        return $this->DepartureDate;
    }

    public function setDepartureDate(?\DateTime $DepartureDate): Expatriate
    {
        $this->DepartureDate = $DepartureDate;
        return $this;
    }

    public function getLatitude(): ?float
    {
        return $this->Latitude;
    }

    public function setLatitude(?float $Latitude): Expatriate
    {
        $this->Latitude = $Latitude;
        return $this;
    }

    public function getLongitude(): ?float
    {
        return $this->Longitude;
    }

    public function setLongitude(?float $Longitude): Expatriate
    {
        $this->Longitude = $Longitude;
        return $this;
    }

    public function getImageRepository(): ?string
    {
        return $this->ImageRepository;
    }

    public function setImageRepository(?string $ImageRepository): Expatriate
    {
        $this->ImageRepository = $ImageRepository;
        return $this;
    }

    public function getImageFileName(): ?string
    {
        return $this->ImageFileName;
    }

    public function setImageFileName(?string $ImageFileName): Expatriate
    {
        $this->ImageFileName = $ImageFileName;
        return $this;
    }

    public function getGender(): ?string
    {
        return $this->Gender;
    }

    public function setGender(?string $Gender): Expatriate
    {
        $this->Gender = $Gender;
        return $this;
    }

    public function getAge(): ?int
    {
        return $this->Age;
    }

    public function setAge(?int $Age): Expatriate
    {
        $this->Age = $Age;
        return $this;
    }

    public function getUsername(): ?string
    {
        return $this->Username;
    }

    public function setUsername(?string $Username): Expatriate
    {
        $this->Username = $Username;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->Description;
    }

    public function setDescription(?string $Description): Expatriate
    {
        $this->Description = $Description;
        return $this;
    }
    public function getCountry(): ?string
    {
        return $this->Country;
    }

    public function setCountry(?string $Country): Expatriate
    {
        $this->Country = $Country;
        return $this;
    }

    public static function SqlAdd(Expatriate $expatriate)
    {
        try {
            $request = BDD::getInstance()->prepare("
            INSERT INTO expatriate (
                Firstname, Lastname, Email, ArrivalDate, DepartureDate, Latitude, Longitude, Country,
                ImageRepository, ImageFileName, Gender, Age, Username, Description
            ) VALUES (
                :Firstname, :Lastname, :Email, :ArrivalDate, :DepartureDate, :Latitude, :Longitude, :Country,
                :ImageRepository, :ImageFileName, :Gender, :Age, :Username, :Description
            )
        ");

            $request->bindValue(':Firstname', $expatriate->getFirstname());
            $request->bindValue(':Lastname', $expatriate->getLastname());
            $request->bindValue(':Email', $expatriate->getEmail());
            $request->bindValue(':ArrivalDate', $expatriate->getArrivalDate()?->format('Y-m-d'));
            $request->bindValue(':DepartureDate', $expatriate->getDepartureDate()?->format('Y-m-d'));
            $request->bindValue(':Latitude', $expatriate->getLatitude());
            $request->bindValue(':Longitude', $expatriate->getLongitude());
            $request->bindValue(':Country', $expatriate->getCountry());
            $request->bindValue(':ImageRepository', $expatriate->getImageRepository());
            $request->bindValue(':ImageFileName', $expatriate->getImageFileName());
            $request->bindValue(':Gender', $expatriate->getGender());
            $request->bindValue(':Age', $expatriate->getAge());
            $request->bindValue(':Username', $expatriate->getUsername());
            $request->bindValue(':Description', $expatriate->getDescription());

            $request->execute();

            return BDD::getInstance()->lastInsertId();
        } catch (\PDOException $e) {
            return $e->getMessage();
        }
    }


    public static function SqlGetAll($limit = null, $offset = null)
    {
        $sql = 'SELECT * FROM expatriate ORDER BY Id DESC';

        if ($limit !== null && $offset !== null) {
            $sql .= ' LIMIT :limit OFFSET :offset';
        }

        $request = BDD::getInstance()->prepare($sql);

        if ($limit !== null && $offset !== null) {
            $request->bindValue(':limit', (int) $limit, \PDO::PARAM_INT);
            $request->bindValue(':offset', (int) $offset, \PDO::PARAM_INT);
        }

        $request->execute();
        $expatriatesSql = $request->fetchAll(\PDO::FETCH_ASSOC);
        $expatriatesObjet = [];

        foreach ($expatriatesSql as $expatriateSql) {
            $expatriate = new Expatriate();
            $expatriate->setId($expatriateSql['Id'])
                ->setFirstname($expatriateSql['Firstname'])
                ->setLastname($expatriateSql['Lastname'])
                ->setEmail($expatriateSql['Email'])
                ->setArrivalDate(new \DateTime($expatriateSql['ArrivalDate']))
                ->setDepartureDate(!empty($expatriateSql['DepartureDate']) ? new \DateTime($expatriateSql['DepartureDate']) : null)
                ->setLatitude($expatriateSql['Latitude'])
                ->setLongitude($expatriateSql['Longitude'])
                ->setCountry($expatriateSql['Country'])
                ->setImageRepository($expatriateSql['ImageRepository'])
                ->setImageFileName($expatriateSql['ImageFileName'])
                ->setAge($expatriateSql['Age'])
                ->setUsername($expatriateSql['Username'])
                ->setDescription($expatriateSql['Description'])
                ->setGender($expatriateSql['Gender']);
            $expatriatesObjet[] = $expatriate;
        }

        return $expatriatesObjet;
    }


    public static function SqlGetById( int $Id)
    {
        $request = BDD::getInstance()->prepare('SELECT * FROM expatriate WHERE Id = :Id');
        $request->bindValue(':Id', $Id);
        $request->execute();
        $expatriateSql = $request->fetch(\PDO::FETCH_ASSOC);

        if (!$expatriateSql) {
            return null;
        }

        $expatriate = new Expatriate();
        $expatriate->setId($expatriateSql["Id"])
            ->setFirstname($expatriateSql["Firstname"])
            ->setLastname($expatriateSql["Lastname"])
            ->setEmail($expatriateSql["Email"])
            ->setArrivalDate(new \DateTime($expatriateSql["ArrivalDate"]))
            ->setDepartureDate(!empty($expatriateSql["DepartureDate"]) ? new \DateTime($expatriateSql["DepartureDate"]) : null)
        ->setLatitude($expatriateSql["Latitude"])
            ->setLongitude($expatriateSql["Longitude"])
            ->setCountry($expatriateSql["Country"])
            ->setImageRepository($expatriateSql["ImageRepository"])
            ->setImageFileName($expatriateSql["ImageFileName"])
            ->setAge($expatriateSql["Age"])
            ->setUsername($expatriateSql["Username"])
            ->setDescription($expatriateSql["Description"])
            ->setGender($expatriateSql["Gender"]);
        return $expatriate;
    }

    public static function SqlUpdate(Expatriate $expatriate)
    {
        try {
            $request = BDD::getInstance()->prepare("
            UPDATE expatriate SET 
                Firstname = :Firstname, 
                Lastname = :Lastname, 
                Email = :Email, 
                ArrivalDate = :ArrivalDate, 
                DepartureDate = :DepartureDate, 
                Latitude = :Latitude, 
                Longitude = :Longitude, 
                ImageRepository = :ImageRepository, 
                ImageFileName = :ImageFileName,
                Gender = :Gender,
                Age = :Age,
                Username = :Username,
                Description = :Description,
                Country = :Country
            WHERE Id = :Id  
        ");

            $request->bindValue(':Id', $expatriate->getId());
            $request->bindValue(':Firstname', $expatriate->getFirstname());
            $request->bindValue(':Lastname', $expatriate->getLastname());
            $request->bindValue(':Email', $expatriate->getEmail());
            $request->bindValue(':ArrivalDate', $expatriate->getArrivalDate()?->format('Y-m-d'));
            $request->bindValue(':DepartureDate', $expatriate->getDepartureDate()?->format('Y-m-d'));
            $request->bindValue(':Latitude', $expatriate->getLatitude());
            $request->bindValue(':Longitude', $expatriate->getLongitude());
            $request->bindValue(':ImageRepository', $expatriate->getImageRepository());
            $request->bindValue(':ImageFileName', $expatriate->getImageFileName());
            $request->bindValue(':Gender', $expatriate->getGender());
            $request->bindValue(':Age', $expatriate->getAge());
            $request->bindValue(':Username', $expatriate->getUsername());
            $request->bindValue(':Description', $expatriate->getDescription());
            $request->bindValue(':Country', $expatriate->getCountry());
            $request->execute();
            return $request->rowCount() > 0;
        } catch (\PDOException $e) {
            return $e->getMessage();
        }
    }

    public static function SqlDelete(int $Id)
    {
        try {

        $request = BDD::getInstance()->prepare('DELETE FROM expatriate WHERE Id = :Id');
        $request->bindValue(':Id', $Id);
        $request->execute();
        return $request->rowCount() > 0;
        }catch (\PDOException $e){
            return $e->getMessage();
        }
    }

    public static function SqlGetByUser(string $username)
    {
        $request = BDD::getInstance()->prepare('SELECT * FROM expatriate WHERE Username = :Username');
        $request->bindValue(':Username', $username);
        $request->execute();

        $expatriatesSql = $request->fetchAll(\PDO::FETCH_ASSOC);
        $expatriates = [];
        foreach ($expatriatesSql as $expatriateSql) {
            $expatriate = new Expatriate();
            $expatriate->setId($expatriateSql["Id"])
                ->setFirstname($expatriateSql["Firstname"])
                ->setLastname($expatriateSql["Lastname"])
                ->setEmail($expatriateSql["Email"])
                ->setArrivalDate(new \DateTime($expatriateSql["ArrivalDate"]))
                ->setDepartureDate(!empty($expatriateSql["DepartureDate"]) ? new \DateTime($expatriateSql["DepartureDate"]) : null)
                ->setLatitude($expatriateSql["Latitude"])
                ->setLongitude($expatriateSql["Longitude"])
                ->setCountry($expatriateSql["Country"])
                ->setImageRepository($expatriateSql["ImageRepository"])
                ->setImageFileName($expatriateSql["ImageFileName"])
                ->setAge($expatriateSql["Age"])
                ->setUsername($expatriateSql["Username"])
                ->setDescription($expatriateSql["Description"])
                ->setGender($expatriateSql["Gender"]);
            $expatriates[] = $expatriate;
        }
        return $expatriates;
    }

    public static function SqlGetAllFiltered($limit = null, $offset = null, $country = null, $startDate = null, $endDate = null)
    {
        $sql = 'SELECT * FROM expatriate WHERE 1=1';

        if ($country !== null) {
            $sql .= ' AND Country = :country';
        }
        
        if ($startDate !== null && $endDate !== null) {
            $sql .= ' AND (ArrivalDate <= :endDate) AND (DepartureDate >= :startDate OR DepartureDate IS NULL)';
        } else if ($startDate !== null) {
            $sql .= ' AND (DepartureDate >= :startDate OR DepartureDate IS NULL)';
        } else if ($endDate !== null) {
            $sql .= ' AND (ArrivalDate <= :endDate)';
        }

        $sql .= ' ORDER BY Id DESC';

        if ($limit !== null && $offset !== null) {
            $sql .= ' LIMIT :limit OFFSET :offset';
        }

        $request = BDD::getInstance()->prepare($sql);

        if ($country !== null) {
            $request->bindValue(':country', $country);
        }

        if ($startDate !== null) {
            $request->bindValue(':startDate', $startDate);
        }

        if ($endDate !== null) {
            $request->bindValue(':endDate', $endDate);
        }

        if ($limit !== null && $offset !== null) {
            $request->bindValue(':limit', (int) $limit, \PDO::PARAM_INT);
            $request->bindValue(':offset', (int) $offset, \PDO::PARAM_INT);
        }

        $request->execute();
        $expatriatesSql = $request->fetchAll(\PDO::FETCH_ASSOC);
        $expatriatesObjet = [];

        foreach ($expatriatesSql as $expatriateSql) {
            $expatriate = new Expatriate();
            $expatriate->setId($expatriateSql['Id'])
                ->setFirstname($expatriateSql['Firstname'])
                ->setLastname($expatriateSql['Lastname'])
                ->setEmail($expatriateSql['Email'])
                ->setArrivalDate(new \DateTime($expatriateSql['ArrivalDate']))
                ->setDepartureDate(!empty($expatriateSql['DepartureDate']) ? new \DateTime($expatriateSql['DepartureDate']) : null)
                ->setLatitude($expatriateSql['Latitude'])
                ->setLongitude($expatriateSql['Longitude'])
                ->setCountry($expatriateSql['Country'])
                ->setImageRepository($expatriateSql['ImageRepository'])
                ->setImageFileName($expatriateSql['ImageFileName'])
                ->setAge($expatriateSql['Age'])
                ->setUsername($expatriateSql['Username'])
                ->setDescription($expatriateSql['Description'])
                ->setGender($expatriateSql['Gender']);
            $expatriatesObjet[] = $expatriate;
        }

        return $expatriatesObjet;
    }



    public function jsonSerialize(): mixed
    {
        return [
            "Id" => $this->Id,
            "Firstname" => $this->FirstName,
            "Lastname" => $this->LastName,
            "Email" => $this->Email,
            "ArrivalDate" => $this->ArrivalDate?->format('Y-m-d'),
            "DepartureDate" => $this->DepartureDate?->format('Y-m-d'),
            "Latitude" => $this->Latitude,
            "Longitude" => $this->Longitude,
            "Country" => $this->Country,
            "ImageRepository" => $this->ImageRepository,
            "ImageFileName" => $this->ImageFileName,
            "Gender" => $this->Gender,
            "Age" => $this->Age,
            "Username" => $this->Username,
            "Description" => $this->Description
        ];
    }



}
