<?php

namespace App\MessageHandler;

use App\Message\ContactEmailMessage;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
class ContactEmailMessageHandler
{
    public function __construct(
        private readonly MailerInterface $mailer,
        private readonly string $mailFrom,
        private readonly string $mailTo,
    ) {}

    public function __invoke(ContactEmailMessage $message): void
    {
        $email = (new Email())
            ->from($this->mailFrom)
            ->to($this->mailTo)
            ->replyTo($message->email)
            ->subject($message->subject ?? 'Nouveau message depuis le portfolio')
            ->text(
                "Nom : {$message->name}\n" .
                "Email : {$message->email}\n\n" .
                "Message :\n{$message->message}"
            )
            ->html(
                $this->buildHtmlTemplate($message)
            );

        $this->mailer->send($email);
    }

    private function buildHtmlTemplate(ContactEmailMessage $message): string
    {
        return sprintf(
            "<h2>Nouveau message de %s</h2>
            <p><strong>Email :</strong> %s</p>
            <hr>
            <p>%s</p>",
            htmlspecialchars($message->name),
            htmlspecialchars($message->email),
            nl2br(htmlspecialchars($message->message))
        );
    }
}