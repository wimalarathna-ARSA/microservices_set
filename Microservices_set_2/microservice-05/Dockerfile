FROM ruby:3.1
WORKDIR /app
COPY Gemfile ./
RUN bundle install
COPY . .
EXPOSE 3005
CMD ["ruby", "app.rb"]
