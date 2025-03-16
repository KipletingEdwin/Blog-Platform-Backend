#!/usr/bin/env bash
# Exit script on any error
set -o errexit

# Install dependencies
bundle install

# Precompile assets for production
bundle exec rails assets:precompile

# Clean up assets
bundle exec rails assets:clean


