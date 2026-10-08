FROM php:8.2-alpine
WORKDIR /app
RUN apk add --no-cache libzip-dev unzip && docker-php-ext-install zip
COPY composer.json ./
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader
COPY . .
EXPOSE 3006
CMD ["php", "-S", "0.0.0.0:3006", "index.php"]
