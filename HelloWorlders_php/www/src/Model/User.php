<?php

namespace Src\Model;

class User
{
    private ?int $Id = null;
    private string $Email;
    private string $Password;

    public function getId(): ?int
    {
        return $this->Id;
    }

    public function setId(?int $Id): User
    {
        $this->Id = $Id;
        return $this;
    }

    public function getEmail(): string
    {
        return $this->Email;
    }

    public function setEmail(string $Email): User
    {
        $this->Email = $Email;
        return $this;
    }

    public function getPassword(): string
    {
        return $this->Password;
    }

    public function setPassword(string $Password): User
    {
        $this->Password = $Password;
        return $this;
    }

    public static function SqlAdd(User $user): int
    {
        $requete = BDD::getInstance()->prepare("INSERT INTO user (Email, Password ) VALUES(:Email, :Password)");
        $requete->execute([
            "Email" => $user->getEmail(),
            "Password" => $user->getPassword(),
        ]);
        return BDD::getInstance()->lastInsertId();
    }

    public static function SqlGetByMail(string $mail): ?User
    {
        $requete = BDD::getInstance()->prepare("SELECT * FROM user WHERE Email=:mail");
        $requete->execute([
            "mail" => $mail
        ]);
        $datas = $requete->fetch(\PDO::FETCH_ASSOC);
        if($datas != false){
            $user = new User();
            $user->setId($datas["Id"])
                ->setEmail($datas["Email"])
                ->setPassword($datas["Password"]);
            return $user;
        }
        return null;
    }
}