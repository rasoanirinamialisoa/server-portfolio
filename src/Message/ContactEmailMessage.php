<?php

namespace App\Message;

class ContactEmailMessage
{
    public function __construct(
        public readonly string $name,
        public readonly string $email,
        public readonly string $message,
        public readonly ?string $subject = null,
    ) {}
}