<?php

namespace src\Controller;

class ErrorController extends AbstractController
{
    public function error($message)
    {
        return $this->twig->render('Error/error.html.twig', ['message' => $message]);
    }

}