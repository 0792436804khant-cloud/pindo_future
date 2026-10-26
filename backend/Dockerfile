FROM php:8.4-cli-alpine

# Use official trusted extension installer to guarantee clean Alpine compilation
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_pgsql redis bcmath opcache zip pcntl

# Install system utilities
RUN apk add --no-cache git curl unzip bash

# Install Composer v2
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy repo content
COPY . /var/www/

# Handle both root context (where backend/ exists) and subfolder context
RUN if [ -f /var/www/backend/composer.json ]; then \
      cp -r /var/www/backend/* /var/www/ && rm -rf /var/www/backend /var/www/mobile; \
    fi

# Temporary minimal .env to satisfy framework requirements during build
RUN cp .env.example .env 2>/dev/null || touch .env

# Install composer packages with --ignore-platform-reqs for maximum compatibility
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Storage directory initialization and permissions
RUN rm -rf /var/www/bootstrap/cache/*.php /var/www/.env* \
    && mkdir -p /var/www/storage/framework/sessions \
    && mkdir -p /var/www/storage/framework/views \
    && mkdir -p /var/www/storage/framework/cache \
    && mkdir -p /var/www/bootstrap/cache \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

ENV PORT=8080
EXPOSE 8080

# Robust runtime startup: purge env/cache, discover packages, migrate, compile config & route cache, and serve
CMD ["sh", "-c", "rm -f /var/www/.env /var/www/.env.* /var/www/bootstrap/cache/*.php && php artisan package:discover --ansi && if [ -z \"$APP_KEY\" ]; then php artisan key:generate --force; fi && php artisan migrate --force && php artisan db:seed --force && php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
