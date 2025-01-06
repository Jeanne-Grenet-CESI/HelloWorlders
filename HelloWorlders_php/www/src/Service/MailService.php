<?php
namespace src\Service;

use Symfony\Component\Mailer\Mailer;
use Symfony\Component\Mailer\Transport;
use Symfony\Component\Mime\Email;

class MailService
{

    private Mailer $mailer;

    public function __construct()
    {
        $transport = Transport::fromDsn("smtp://462155d877a788:06544a24919fdd@sandbox.smtp.mailtrap.io:2525");
        $this->mailer = new Mailer($transport);
    }

    public function send(array|String $from, array|String $to, String $subjet, String $html){
        //Concevoir le message
        $email = (new Email())
            ->from($from)
            ->to($to)
            ->subject($subjet)
            ->html($html);

        //Envoyer le message
        $this->mailer->send($email);

    }

}