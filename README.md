# Portfolio Symfony API

Backend Symfony utilisé pour gérer le formulaire de contact du portfolio et l'envoi d'e-mails via Brevo.

## Description

Cette API reçoit les messages envoyés depuis le portfolio React et les transmet par e-mail grâce à Brevo.

## Technologies

- Symfony 7
- PHP 8
- Symfony Mailer
- Brevo SMTP
- Composer

## Installation

Cloner le projet :

```bash
git clone https://github.com/rasoanirinamialisoa/server-portfolio
```

Accéder au dossier :

```bash
cd portfolio
```

Installer les dépendances :

```bash
composer install
```

Configurer les variables d'environnement dans `.env` :

```env
MAILER_DSN=brevo+api:***
MAIL_FROM=example@.com
MAIL_TO=example@.com

```

Lancer le serveur :

```bash
symfony server:start
```

ou

```bash
php -S localhost:8000 -t public
```

## Fonctionnalités

- Réception des messages du formulaire de contact
- Validation des données
- Envoi d'e-mails via Brevo
- Gestion des erreurs d'envoi

## Structure du projet

```text
src/
├── Controller/
├── Entity/
└── Repository/
```

## Auteur

Mialisoa Lisa Rasoanirina

- GitHub : https://github.com/rasoanirinamialisoa
- LinkedIn : https://www.linkedin.com/in/mialisoa-lisa-rasoanirina-0028b3148/