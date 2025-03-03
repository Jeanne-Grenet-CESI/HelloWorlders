<?php
namespace src\Controller;

use src\Service\CsrfTokenService;
use src\Service\MailService;

abstract class AbstractController
{
    protected $twig = null;
    protected MailService $mailService;
    protected CsrfTokenService $csrfTokenService;

    public function __construct()
    {

        $this->csrfTokenService = new CsrfTokenService();

        $loader = new \Twig\Loader\FilesystemLoader($_SERVER['DOCUMENT_ROOT'].'/../src/View');
        $this->twig = new \Twig\Environment($loader, [
            'cache' => $_SERVER['DOCUMENT_ROOT'].'/../var/cache',
            'debug' => true,
        ]);
        $this->twig->addExtension(new \Twig\Extension\DebugExtension());

        $fileExist = new \Twig\TwigFunction('file_exist', function($fullfilename){
            return file_exists($fullfilename);
        });
        $this->twig->addFunction($fileExist);
        $this->twig->addGlobal('session', $_SESSION);
        $this->twig->addGlobal('csrf_token', $this->csrfTokenService->getToken());

        $this->mailService = new MailService();
    }
    
    protected function isValidCsrfToken(): bool
    {
        if (!isset($_POST['csrf_token'])) {
            return false;
        }

        return $this->csrfTokenService->validateToken($_POST['csrf_token']);
    }
}