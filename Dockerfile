# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.2.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# ✅ Install PostgreSQL development libraries (Fix for `pg` gem issue)
RUN apt-get update -qq && apt-get install -y libpq-dev build-essential git pkg-config

# ✅ Install Bundler and update gems
RUN gem install bundler -v 2.3.26

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# ✅ Run `bundle install` without cache and ensure PostgreSQL gem is properly installed
RUN bundle install --no-cache --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# ✅ Set correct Rails entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# ✅ Expose correct Rails port
EXPOSE 3000

# ✅ Start the Rails server properly
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
