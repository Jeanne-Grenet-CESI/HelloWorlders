<?php
namespace src\Service;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtService
{
    public static String $secretKey = "helloWorlders";

    public static function createToken(array $datas) : string
    {
        $issuedAt = new \DateTimeImmutable();
        $expire = $issuedAt->modify("+1 minutes")->getTimestamp();
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

        if (!preg_match('/Bearer\s(\S+)/', $_SERVER['HTTP_AUTHORIZATION'], $matches
        )) {
            return ["status" => "error", "message" => "Token not found"];
        }
        $jwt = $matches[1];
        if(!$jwt){
            return ["status" => "error", "message" => "Token could not be extracted"];
        }
        try {
            $token = JWT::decode($jwt, new Key(self::$secretKey, 'HS256') );
        } catch (\Exception $exception) {
            return ["status" => "error", "message" => $exception->getMessage()];
        }
        $now = new \DateTimeImmutable();
        $serverName = "cesi.local";
        if($token->iss !== $serverName || $token->nbf > $now->getTimestamp() || $token->exp < $now->getTimestamp()){
            return ["status" => "error", "message" => "Invalid Token"];
        }
        return ["status" => "success", "message" => "Token validated", "data" => json_decode(CryptService::decrypt($token->data))];
    }
}
