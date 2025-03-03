<?php
namespace src\Service;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtService
{
    public static String $secretKey = "helloworlders";

    public static function createToken(array $datas) : string
    {
        $issuedAt = new \DateTimeImmutable();
        $expire = $issuedAt->modify("+10 minutes")->getTimestamp();
        $serverName = "helloworlders.local";
        $data = [
            "iat" => $issuedAt->getTimestamp(),
            "iss" => $serverName,
            "nbf" => $issuedAt->getTimestamp(),
            "exp" => $expire,
            "data" => CryptService::encrypt(json_encode($datas))


        ];
        $jwt = JWT::encode($data, self::$secretKey, 'HS256');
        return $jwt;
    }

    public static function checkToken() : array
    {
        if (! preg_match('/Bearer\s(\S+)/', $_SERVER['HTTP_AUTHORIZATION'], $matches
        )) {
            return ["status" => "error", "message" => "Token non trouvé"];
        }
        $jwt = $matches[1];
        if(!$jwt){
            return ["status" => "error", "message" => "Aucun token n'a pu être extrait"];
        }
        try {
            $token = JWT::decode($jwt, new Key(self::$secretKey, 'HS256') );
        } catch (\Exception $exception) {
            return ["status" => "error", "message" => $exception->getMessage()];
        }
        $now = new \DateTimeImmutable();
        $serverName = "helloworlders.local";
        if($token->iss !== $serverName || $token->nbf > $now->getTimestamp() || $token->exp < $now->getTimestamp()){
            return ["status" => "error", "message" => "Token invalide"];
        }
        return ["status" => "success", "message" => "Token JWT valide", "data" => json_decode(CryptService::decrypt($token->data))];
    }
}