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

# Copy the backend files into /var/www
COPY backend/ /var/www/

# Ensure a base .env exists for package discovery during build
RUN cp .env.example .env 2>/dev/null || touch .env

RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Ensure storage directories exist and have proper permissions
RUN mkdir -p /var/www/storage/framework/sessions \
    && mkdir -p /var/www/storage/framework/views \
    && mkdir -p /var/www/storage/framework/cache \
    && mkdir -p /var/www/bootstrap/cache \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

ENV PORT=8080
EXPOSE 8080

# Safe entrypoint: auto-generate key if missing, run migrations, cache config, and start server
CMD ["sh", "-c", "if [ -z \"$APP_KEY\" ]; then php artisan key:generate --force; fi && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
