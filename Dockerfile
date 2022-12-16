FROM sylhare/type-on-strap:latest

WORKDIR /app
COPY . /app

RUN gem install bundle
RUN bundle update
RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve","--host", "0.0.0.0"]