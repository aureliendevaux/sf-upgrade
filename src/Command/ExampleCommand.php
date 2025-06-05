<?php

namespace App\Command;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\Argument;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

#[AsCommand(
    name: 'app:example',
    description: 'Add a short description for your command',
)]
readonly class ExampleCommand
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private UserPasswordHasherInterface $passwordHasher,
    ) {
    }

    public function __invoke(
        SymfonyStyle $io,
        #[Argument] string $email,
    ): int {
        $user = new User();
        $user
            ->setEmail($email)
            ->setPassword($this->passwordHasher->hashPassword($user, 'password'))
        ;

        $this->entityManager->persist($user);
        $this->entityManager->flush();

        $io->success('User created successfully with email: ' . $email);

        return Command::SUCCESS;
    }
}
