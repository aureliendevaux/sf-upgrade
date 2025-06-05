FROM php:8.4-apache

# Suppress Apache warning about ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Create default VirtualHost
COPY "./docker/vhost.conf" "/etc/apache2/sites-enabled/000-default.conf"

# Override some php.ini configuration for our needs
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
COPY "./docker/php.ini" "/usr/local/etc/php/conf.d/php-overrides.ini"

# Install tool to manage PHP extensions as official Docker images
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install required PHP extensions
RUN chmod +x /usr/local/bin/install-php-extensions; \
    install-php-extensions intl zip pdo_pgsql pgsql bcmath xsl gd @composer;

# Install symfony-cli
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash; \
    apt-get install -y symfony-cli;

# Enable mod_rewrite module for Apache
RUN a2enmod rewrite

# Install latest stable node version
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm;

# Set working directory
WORKDIR /var/www/html/
