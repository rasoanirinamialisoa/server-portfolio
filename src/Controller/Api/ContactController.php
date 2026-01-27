<?php

namespace App\Controller\Api;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class ContactController extends AbstractController
{
    #[Route('/api/contact', name: 'api_contact', methods: ['POST'])]
    public function send(
        Request $request,
        MailerInterface $mailer
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (
            empty($data['name']) ||
            empty($data['email']) ||
            empty($data['message'])
        ) {
            return new JsonResponse([
                'success' => false,
                'message' => 'Champs manquants'
            ], 400);
        }

        $email = (new Email())
            ->from($_ENV['MAIL_FROM'])
            ->to($_ENV['MAIL_TO'])
            ->replyTo($data['email'])
            ->subject('Nouveau message depuis le portfolio')
            ->text(
                "Nom : {$data['name']}\n" .
                "Email : {$data['email']}\n\n" .
                "Message :\n{$data['message']}"
        );

        $mailer->send($email);

        return new JsonResponse(['success' => true]);
    }
}
