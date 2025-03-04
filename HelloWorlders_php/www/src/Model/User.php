<?php

namespace Src\Model;

class User
{
    private ?int $Id = null;
    private string $Email;
    private string $Password;

    private string $Username;

    private bool $IsAdmin = false;

    public function setIsAdmin(bool $IsAdmin): User
    {
        $this->IsAdmin = $IsAdmin ? 1 : 0;
        return $this;
    }

    public function getIsAdmin(): bool
    {
        return (bool) $this->IsAdmin;
    }

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

    public function getUsername(): string
    {
        return $this->Username;
    }

    public function setUsername(string $Username): User
    {
        $this->Username = $Username;
        return $this;
    }

    public static function SqlAdd(User $user): int
    {
        $request = BDD::getInstance()->prepare("
        INSERT INTO user (Email, Password, Username, IsAdmin)
        VALUES (:Email, :Password, :Username, :IsAdmin)
    ");
        $request->execute([
            "Email" => $user->getEmail(),
            "Password" => $user->getPassword(),
            "Username" => $user->getUsername(),
            "IsAdmin" => 0
        ]);
        return BDD::getInstance()->lastInsertId();
    }


    public static function SqlGetByMail(string $mail): ?User
    {
        $request = BDD::getInstance()->prepare("SELECT * FROM user WHERE Email=:mail");
        $request->execute([
            "mail" => $mail
        ]);
        $data = $request->fetch(\PDO::FETCH_ASSOC);
        if ($data != false) {
            $user = new User();
            $user->setId($data["Id"])
                ->setEmail($data["Email"])
                ->setPassword($data["Password"])
                ->setUsername($data["Username"])
                ->setIsAdmin($data["IsAdmin"]);
            return $user;
        }
        return null;
    }

    public static function checkUserExistence($email, $username): array
    {
        $request = BDD::getInstance()->prepare("SELECT Email, Username FROM user WHERE Email=:email OR Username=:username");
        $request->execute([
            "email" => $email,
            "username" => $username
        ]);

        $result = ["emailExists" => false, "usernameExists" => false];

        while ($data = $request->fetch(\PDO::FETCH_ASSOC)) {
            if ($data["Email"] === $email) {
                $result["emailExists"] = true;
            }
            if ($data["Username"] === $username) {
                $result["usernameExists"] = true;
            }
        }

        return $result;
    }
}