CWD := `docker compose exec php pwd`
TOOLS_DIR := CWD + "/tools"
COMPOSE_TOOLING := "docker compose exec php"
COMPOSE_COMPOSER := COMPOSE_TOOLING + " composer"
COMPOSE_SYMFONY := COMPOSE_TOOLING + " symfony"
COMPOSE_NPM := COMPOSE_TOOLING + " npm"

# *******************************
# Application related
# *******************************

# Update the database schema
schema:
    {{ COMPOSE_SYMFONY }} console doctrine:schema:update --force

# Create default data
seed:
    {{ COMPOSE_SYMFONY }} console doctrine:fixtures:load --no-interaction

# Create a new migration
migration *arguments:
    {{ COMPOSE_SYMFONY }} console make:migration {{ arguments }}

# Migrate to database
migrate:
    {{ COMPOSE_SYMFONY }} console doctrine:migrations:migrate --no-interaction

# Recreate database
flush:
    {{ COMPOSE_SYMFONY }} console doctrine:database:drop --force
    {{ COMPOSE_SYMFONY }} console doctrine:database:create

# Recreate a fresh database
fresh: flush migrate

# Reset database, update schema and execute commands
reset: flush schema

# Make a migration and migrate automatically
mig: migration migrate

# Clear caches
cc env='dev':
    {{ COMPOSE_SYMFONY }} console cache:clear --env={{ env }}

# Create a new twig component
comp:
    {{ COMPOSE_SYMFONY }} console make:twig-component

# Recompile assets (CSS/JS) on every change
watch:
    {{ COMPOSE_NPM }} run watch

# Compile and optimize assets for production
build:
    {{ COMPOSE_NPM }} run build

# Launch PHPUnit tests
test *path:
    {{ COMPOSE_TOOLING }} php bin/phpunit {{ path }}

# *******************************
# Tools related
# *******************************

# Install php dependencies
install_php:
    {{ COMPOSE_COMPOSER }} install
    {{ COMPOSE_COMPOSER }} install --working-dir={{ TOOLS_DIR }}/composer-require-checker
    {{ COMPOSE_COMPOSER }} install --working-dir={{ TOOLS_DIR }}/phpcsfixer
    {{ COMPOSE_COMPOSER }} install --working-dir={{ TOOLS_DIR }}/phpcs
    {{ COMPOSE_COMPOSER }} install --working-dir={{ TOOLS_DIR }}/phpmd
    {{ COMPOSE_COMPOSER }} install --working-dir={{ TOOLS_DIR }}/phpstan

# Update php dependencies
update_php:
    {{ COMPOSE_COMPOSER }} update
    {{ COMPOSE_COMPOSER }} update --working-dir={{ TOOLS_DIR }}/composer-require-checker
    {{ COMPOSE_COMPOSER }} update --working-dir={{ TOOLS_DIR }}/phpcsfixer
    {{ COMPOSE_COMPOSER }} update --working-dir={{ TOOLS_DIR }}/phpcs
    {{ COMPOSE_COMPOSER }} update --working-dir={{ TOOLS_DIR }}/phpmd
    {{ COMPOSE_COMPOSER }} update --working-dir={{ TOOLS_DIR }}/phpstan

# Install frontend dependencies
install_front:
    {{ COMPOSE_NPM }} install

# composer alias
composer +arguments:
    COMPOSER_ALLOW_SUPERUSER=1 {{ COMPOSE_COMPOSER }} {{ arguments }}

# symfony alias
symfony *arguments:
    {{ COMPOSE_SYMFONY }} {{ arguments }}

# symfony console alias
console *arguments:
    {{ COMPOSE_SYMFONY }} console {{ arguments }}

# php alias
php *arguments:
    {{ COMPOSE_TOOLING }} {{ arguments }}

# npm alias
npm +arguments:
    {{ COMPOSE_NPM }} {{ arguments }}

# Install all dependencies
install: install_php install_front

# Launch PHP CS Fixer (see https://github.com/PHP-CS-Fixer/PHP-CS-Fixer)
fix:
	{{COMPOSE_TOOLING}} {{TOOLS_DIR}}/phpcsfixer/vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.dist.php

# Launch PHPStan (see https://phpstan.org/)
stan *paths='src':
	{{COMPOSE_TOOLING}} {{TOOLS_DIR}}/phpstan/vendor/bin/phpstan analyse -c phpstan.neon {{paths}}

# Launch PHP Mess Detector (see https://phpmd.org/)
phpmd *paths='src,tests':
	{{COMPOSE_TOOLING}} {{TOOLS_DIR}}/phpmd/vendor/bin/phpmd {{paths}} ansi phpmd.xml

# Launch PHP_CodeSniffer (see https://github.com/squizlabs/PHP_CodeSniffer)
phpcs:
	{{COMPOSE_TOOLING}} {{TOOLS_DIR}}/phpcs/vendor/bin/phpcs -s --standard=phpcs.xml

# Launch PHP_CodeBeautifier (see https://github.com/squizlabs/PHP_CodeSniffer)
phpcbf *paths:
	{{COMPOSE_TOOLING}} {{TOOLS_DIR}}/phpcs/vendor/bin/phpcbf --standard=phpcs.xml {{paths}}

# Launch Composer Require Checker (see https://github.com/maglnet/ComposerRequireChecker/)
check_deps:
	{{COMPOSE_TOOLING}} {{TOOLS_DIR}}/composer-require-checker/vendor/bin/composer-require-checker check composer.json

# Launch all linting tools for backend code
lint_php: phpmd phpcs stan fix phpcbf

# Review possible dependencies to upgrade
ncu:
    {{ COMPOSE_NPM }} run deps:upgrade

# Review possible dependencies to upgrade
outdated:
    {{ COMPOSE_COMPOSER }} outdated --strict --direct

# *******************************
# Environment related
# *******************************

# Open a shell in the php container
shell:
    docker compose exec -it php bash
