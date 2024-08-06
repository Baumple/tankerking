import gleam/dict.{type Dict}
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleam/uri
import tankerking/common.{type Prices, ErrorResponse, OkResponse}
import tankerking/error.{
  type TankerError, ApiError, BadRequest, DecodeResponseError,
  DecodeResponseValueError,
}
import tankerking/internal/decoder

pub fn request_price(
  id: String,
  api_key: String,
) -> Result(Dict(String, Option(Prices)), TankerError) {
  request_prices([id], api_key)
}

pub fn request_prices(
  ids: List(String),
  api_key: String,
) -> Result(Dict(String, Option(Prices)), TankerError) {
  let query =
    [#("ids", string.join(ids, ",")), #("apikey", api_key)]
    |> uri.query_to_string

  let assert Ok(url) = uri.parse(common.base_url <> "/prices.php?" <> query)
  let assert Ok(request) = request.from_uri(url)
  let resp =
    request
    |> httpc.send
    |> result.map_error(BadRequest)

  use resp <- result.try(resp)

  let decoded_resp =
    json.decode(resp.body, decoder.decode_price_response)
    |> result.map_error(DecodeResponseError)

  use decoded_resp <- result.try(decoded_resp)
  case decoded_resp {
    OkResponse(value) ->
      decoder.decode_prices(value)
      |> result.map_error(DecodeResponseValueError)

    ErrorResponse(msg) -> Error(ApiError(msg))
  }
}

