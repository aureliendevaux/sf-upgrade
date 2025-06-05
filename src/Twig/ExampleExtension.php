<?php

declare(strict_types=1);

namespace App\Twig;

use Twig\Attribute\AsTwigFunction;

class ExampleExtension
{
    #[AsTwigFunction(name: 'my_date')]
    public function myDate(): string
    {
        return date('Y-m-d H:i:s');
    }
}
