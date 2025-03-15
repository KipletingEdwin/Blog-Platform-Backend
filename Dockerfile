# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.2.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /rails

# Install essential packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips sqlite3 \
    build-essential git pkg-config \
    libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Create a build stage to install dependencies
FROM base AS build

# Install PostgreSQL client library
RUN apt-get update -qq && apt-get install -y libpq-dev

# Install Bundler (if needed)
RUN gem install bundler -v 2.3.26

# Copy Gemfile first (Docker cache optimization)
COPY Gemfile Gemfile.lock ./

# Install gems (including pg)
RUN bundle install --no-cache --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final runtime image
FROM base

# Copy built artifacts (gems & application)
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Ensure Rails runs as a non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entry point for Docker container
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose the correct Rails port
EXPOSE 3000

# Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
