<?php
namespace src\Service;

class CsrfTokenService
{
    private const TOKEN_NAME = 'csrf_token';

    public function getToken(): string
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        if (!isset($_SESSION[self::TOKEN_NAME])) {
            $_SESSION[self::TOKEN_NAME] = bin2hex(random_bytes(32));

        }

        return $_SESSION[self::TOKEN_NAME];
    }

    public function validateToken(string $token): bool
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        if (!isset($_SESSION[self::TOKEN_NAME])) {
            return false;
        }

        return hash_equals($_SESSION[self::TOKEN_NAME], $token);
    }

    public function refreshToken(): string
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $_SESSION[self::TOKEN_NAME] = bin2hex(random_bytes(32));
        return $_SESSION[self::TOKEN_NAME];
    }
}