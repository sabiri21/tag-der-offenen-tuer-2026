FROM erlang:27-alpine AS build

RUN apk add --no-cache gleam

WORKDIR /app
COPY gleam.toml manifest.toml ./
COPY src ./src
COPY priv ./priv

RUN gleam export erlang-shipment

FROM erlang:27-alpine

WORKDIR /app
COPY --from=build /app/build/erlang-shipment ./

EXPOSE 8000
CMD ["sh", "entrypoint.sh", "run"]
