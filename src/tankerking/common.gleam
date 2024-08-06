/// Common types used across endpoints
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}

pub const base_url = "https://creativecommons.tankerkoenig.de/json"

pub type Response {
  OkResponse(value: Dynamic)
  ErrorResponse(msg: String)
}

pub type Station {
  Station(
    id: String,
    name: String,
    brand: String,
    street: String,
    place: String,
    lat: Float,
    lng: Float,
    dist: Float,
    e5: Option(Float),
    e10: Option(Float),
    diesel: Option(Float),
    price: Option(Float),
  )
}

pub type Prices {
  Prices(e5: Option(Float), e10: Option(Float), diesel: Option(Float))
}

pub type FuelType {
  E5
  E10
  Diesel
  All
}

pub fn fule_type_to_string(type_: FuelType) -> String {
  case type_ {
    E5 -> "e5"
    E10 -> "E10"
    Diesel -> "diesel"
    All -> "all"
  }
}

pub type SortBy {
  SortByPrice
  SortByDist
}

pub fn sort_by_to_string(sort_by: SortBy) -> String {
  case sort_by {
    SortByPrice -> "price"
    SortByDist -> "dist"
  }
}
