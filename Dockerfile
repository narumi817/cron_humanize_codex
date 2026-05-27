FROM ruby:3.3

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential pkg-config && \
    rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH="/usr/local/bundle"

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .
RUN chmod +x bin/*

EXPOSE 3001

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3001"]
