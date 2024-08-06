import gleam/dynamic.{type Dynamic}
import gleam/json

pub type TankerError {
  /// Request did not make it through
  BadRequest(Dynamic)
  /// The responsewas malformed
  DecodeResponseError(json.DecodeError)
  /// The json response value of response was malformed
  DecodeResponseValueError(dynamic.DecodeErrors)
  /// The api returned response.ok != true
  ApiError(String)
}
