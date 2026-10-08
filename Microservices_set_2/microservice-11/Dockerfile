FROM elixir:1.14
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs ./
RUN mix deps.get
COPY . .
RUN mix compile
EXPOSE 3011
CMD ["mix", "run", "--no-halt"]