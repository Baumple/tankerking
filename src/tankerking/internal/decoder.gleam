import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import tankerking/common.{
  type Prices, type Response, type Station, ErrorResponse, OkResponse, Prices,
  Station,
}

fn decode_field(
  d: Dynamic,
  f: String,
  t: fn(Dynamic) -> Result(b, DecodeErrors),
) {
  let assert Ok(v) = d |> dynamic.field(f, t)
  v
}

@internal
pub fn decode_list_response(resp: Dynamic) -> Result(Response, DecodeErrors) {
  decode_response(resp, "stations")
}

fn decode_response(
  resp: Dynamic,
  field_name: String,
) -> Result(Response, DecodeErrors) {
  // okay in the response means everything went fine
  let ok = decode_field(resp, "ok", dynamic.bool)
  case ok {
    True ->
      resp
      |> dynamic.field(field_name, dynamic.dynamic)
      |> result.map(OkResponse)
    False -> error_response(resp)
  }
}

fn error_response(resp: Dynamic) -> Result(Response, DecodeErrors) {
  resp
  |> dynamic.field("message", dynamic.string)
  |> result.map(ErrorResponse)
}

@internal
pub fn decode_stations(stations: Dynamic) -> Result(List(Station), DecodeErrors) {
  stations
  |> dynamic.list(decode_station)
}

fn decode_real(i_or_f: Dynamic) -> Result(Float, DecodeErrors) {
  i_or_f
  |> dynamic.any([
    dynamic.float,
    fn(i) {
      i
      |> dynamic.int
      |> result.map(int.to_float)
    },
  ])
}

fn decode_station(search: Dynamic) -> Result(Station, DecodeErrors) {
  use id <- result.try(search |> dynamic.field("id", dynamic.string))
  use name <- result.try(search |> dynamic.field("name", dynamic.string))
  use brand <- result.try(search |> dynamic.field("brand", dynamic.string))
  use street <- result.try(search |> dynamic.field("street", dynamic.string))
  use place <- result.try(search |> dynamic.field("place", dynamic.string))
  use lat <- result.try(search |> dynamic.field("lat", decode_real))
  use lng <- result.try(search |> dynamic.field("lng", decode_real))
  use dist <- result.try(search |> dynamic.field("dist", decode_real))
  use e5 <- result.try(search |> dynamic.optional_field("e5", decode_real))
  use e10 <- result.try(search |> dynamic.optional_field("e10", decode_real))
  use diesel <- result.try(
    search |> dynamic.optional_field("diesel", decode_real),
  )
  use price <- result.try(
    search |> dynamic.optional_field("price", decode_real),
  )

  Ok(Station(
    id:,
    name:,
    brand:,
    street:,
    place:,
    lat:,
    lng:,
    dist:,
    e5:,
    e10:,
    diesel:,
    price:,
  ))
}

@internal
pub fn decode_price_response(resp: Dynamic) -> Result(Response, DecodeErrors) {
  decode_response(resp, "prices")
}

@internal
pub fn decode_prices(
  prices: Dynamic,
) -> Result(Dict(String, Option(Prices)), DecodeErrors) {
  prices |> dynamic.dict(dynamic.string, decode_price)
}

fn decode_price(price: Dynamic) -> Result(Option(Prices), DecodeErrors) {
  use open <- result.try(price |> dynamic.field("status", dynamic.string))

  case open {
    "open" -> {
      let e5 =
        price
        |> dynamic.optional_field("e5", decode_real)
        |> result.unwrap(or: None)
      let e10 =
        price
        |> dynamic.optional_field("e10", decode_real)
        |> result.unwrap(or: None)
      let diesel =
        price
        |> dynamic.optional_field("diesel", decode_real)
        |> result.unwrap(or: None)

      Ok(Some(Prices(e5, e10, diesel)))
    }
    _ -> Ok(None)
  }
}
