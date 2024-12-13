<?php

namespace src\Controller;

use src\Model\Expatriate;

class ExpatriateController extends AbstractController
{
    public function index()
    {
        $expatriates = Expatriate::SqlGetAll();
        return $this->twig->render('expatriate/index.html.twig',['expatriates' => $expatriates]);
    }
}