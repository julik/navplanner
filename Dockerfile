FROM ruby:2.6-alpine AS rack-base

WORKDIR /webapp
COPY Gemfile Gemfile.lock ./
RUN apk update && apk add \
  linux-headers \
  tzdata \
  build-base \
  curl-dev \
  sqlite sqlite-dev \
  git && \
  gem update bundler && \
  bundle install --deployment --without development test  --jobs 4 && \
  rm -rf /usr/local/bundle/cache && \
  apk del build-base linux-headers

# Time to drop privileges and switch workdir to the user itself
RUN adduser -D webapp -h /webapp
USER webapp
COPY --chown="webapp" . /webapp

# Set the correct Rack env
ARG RACK_ENV=development
ENV RACK_ENV=$RACK_ENV

# Now create the result image
FROM rack-base AS app
WORKDIR /webapp

# Tag the image with the git sha, but only _after_ all software is done
# installing/compiling since it creates another Docker layer.
ARG APP_REVISION=unspecified
ENV APP_REVISION=$APP_REVISION
LABEL app_revision=$APP_REVISION

EXPOSE 9292
CMD bundle exec puma --port 9292
