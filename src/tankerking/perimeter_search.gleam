import gleam/float
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result
import gleam/uri
import tankerking/common.{
  type FuelType, type SortBy, type Station, All, ErrorResponse, OkResponse,
  SortByPrice, Station,
}
import tankerking/error.{
  type TankerError, ApiError, BadRequest, DecodeResponseError,
  DecodeResponseValueError,
}
import tankerking/internal/decoder

pub opaque type PerimeterOptions {
  PerimeterOptions(
    lat: Float,
    lng: Float,
    rad: Float,
    type_: FuelType,
    sort: SortBy,
  )
}

/// Construct a *PerimeterOptions* record
/// ## Parameters
/// - `lat` - latitude of location
/// - `lng` - longitude of location
/// - `rad` - search radius in km (**max 25**)
///
/// ## Edge cases:
pub fn new_options(
  lat lat: Float,
  lng lng: Float,
  rad rad: Float,
) -> PerimeterOptions {
  PerimeterOptions(
    lat:,
    lng:,
    rad: float.clamp(rad, min: 0.0, max: 25.0),
    type_: All,
    sort: SortByPrice,
  )
}

/// Set the order in which the items of the response
/// will be returned.
///
/// ## Example
/// import tankerking/perimeter_search as perimeter
/// import tankerking/common.{SortByPrice}
///
/// let options = perimeter.new_search_options()
///   |> perimeter.sort_by(SortByPrice)
pub fn sort_by(opts: PerimeterOptions, sort_by: SortBy) -> PerimeterOptions {
  PerimeterOptions(..opts, sort: sort_by)
}

/// Set the `FuleType` to search for.
/// When the `FuleType` is `All` then the search results <u>will always be sorted
/// by distance</u>
///
/// ## Examples
///
/// ```gleam
/// import tankerking/perimeter_search as perimeter
/// import tankerking/common.{Diesel}
/// ...
/// let options = perimeter.new_search_options()
///   |> perimeter.search_for(Diesel)
/// ```
pub fn search_for(opts: PerimeterOptions, type_: FuelType) -> PerimeterOptions {
  PerimeterOptions(..opts, type_:)
}

/// Executes the actual search for sourrounding gas stations.
///
/// ## Examples
/// ```gleam
/// import tankerking/perimeter_search as perimeter
/// import tankerking/common.{Diesel, OrderByPrice}
/// 
/// let results = perimeter.new_options()
/// |> perimeter.order_by(OrderByPrice)
/// |> perimeter.search_for(Diesel)
/// |> perimeter.search // -> Result(List(Station), TankerError)
/// ```
pub fn search(
  opts: PerimeterOptions,
  api_key: String,
) -> Result(List(Station), TankerError) {
  let query = [
    #("lat", float.to_string(opts.lat)),
    #("lng", float.to_string(opts.lng)),
    #("rad", float.to_string(opts.rad)),
    #("type", common.fule_type_to_string(opts.type_)),
    #("sort", common.sort_by_to_string(opts.sort)),
    #("apikey", api_key),
  ]

  let assert Ok(uri) =
    uri.parse(common.base_url <> "/list.php?" <> uri.query_to_string(query))

  let assert Ok(request) = request.from_uri(uri)
  let resp =
    request
    |> httpc.send
    |> result.map_error(BadRequest)

  use resp <- result.try(resp)
  let decoded_resp =
    json.decode(resp.body, decoder.decode_list_response)
    |> result.map_error(DecodeResponseError)

  use decoded_resp <- result.try(decoded_resp)

  case decoded_resp {
    OkResponse(dyn_stations) ->
      decoder.decode_stations(dyn_stations)
      |> result.map_error(DecodeResponseValueError)

    ErrorResponse(msg) -> Error(ApiError(msg))
  }
}
