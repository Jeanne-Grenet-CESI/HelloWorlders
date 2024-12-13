<?php
namespace Src\Model;
class Expatriate {
    private ?int $Id = null;
    private ?string $FirstName = null;
    private ?string $LastName = null;
    private ?string $Email = null;
    private ?\DateTime $ArrivalDate = null;
    private ?\DateTime $DepartureDate = null;
    private ?float $Latitude = null;
    private ?float $Longitude = null;
    private ?string $ImageRepository = null;
    private ?string $ImageFileName = null;
    private ?Gender $Gender = null;
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

    public function getFirstName(): ?string
    {
        return $this->FirstName;
    }

    public function setFirstName(?string $FirstName): Expatriate
    {
        $this->FirstName = $FirstName;
        return $this;
    }

    public function getLastName(): ?string
    {
        return $this->LastName;
    }

    public function setLastName(?string $LastName): Expatriate
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

    public function getGender(): ?Gender
    {
        return $this->Gender;
    }

    public function setGender(?Gender $Gender): Expatriate
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
}

enum Gender: string
{
    case Men = 'men';
    case Women = 'women';
    case Other = 'other';
}