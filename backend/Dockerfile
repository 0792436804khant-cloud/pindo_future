FROM php:8.2-cli-alpine

# Install system dependencies, PostgreSQL, Redis, OPcache
RUN apk add --no-cache \
    postgresql-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    $PHPIZE_DEPS \
    && docker-php-ext-install pdo pdo_pgsql bcmath opcache \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del $PHPIZE_DEPS

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . /var/www

# Relocate files if context was root
RUN if [ -f /var/www/backend/composer.json ]; then \
      cp -r /var/www/backend/* /var/www/ && rm -rf /var/www/backend /var/www/mobile; \
    fi

RUN cp .env.example .env 2>/dev/null || touch .env

RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

RUN mkdir -p /var/www/storage/framework/sessions \
    && mkdir -p /var/www/storage/framework/views \
    && mkdir -p /var/www/storage/framework/cache \
    && mkdir -p /var/www/bootstrap/cache \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "if [ -z \"$APP_KEY\" ]; then php artisan key:generate --force; fi && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
