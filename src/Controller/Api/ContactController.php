<?php

namespace App\Controller\Api;

use App\Message\ContactEmailMessage;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class ContactController extends AbstractController
{
    #[Route('/api/contact', name: 'api_contact', methods: ['POST'])]
    public function send(
        Request $request,
        MessageBusInterface $bus
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        // Validation
        if (empty($data['name']) || empty($data['email']) || empty($data['message'])) {
            return $this->json([
                'success' => false,
                'message' => 'Champs manquants'
            ], 400);
        }

        // Validation email
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            return $this->json([
                'success' => false,
                'message' => 'Email invalide'
            ], 400);
        }

        // Envoyer le message dans la file d'attente (asynchrone)
        $bus->dispatch(new ContactEmailMessage(
            $data['name'],
            $data['email'],
            $data['message'],
            $data['subject'] ?? null
        ));

        // Retourner immédiatement (l'email sera envoyé en arrière-plan)
        return $this->json([
            'success' => true,
            'message' => 'Votre message a été envoyé avec succès'
        ]);
    }
}