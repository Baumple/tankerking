# tankerking

<!--[![Package Version](https://img.shields.io/hexpm/v/tankerking)](https://hex.pm/packages/tankerking) -->
<!--[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tankerking/)         -->

```gleam
import tankerking/common
import tankerking/perimeter_search as search

const api_key = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

pub fn main() {
  let latitude = 53.075625769833046
  let longitude = 10.216745759831163
  let radius = 13.0 // km

  let opts =
    search.new_options(lat: latitude, lng: longitude, rad: radius)
    |> search.search_for(common.Diesel)
    |> search.sort_by(common.SortByPrice)

  let assert Ok(results) = search.search(opts, api_key) // -> List(common.Station)
}
```

Further documentation can be found at <https://hexdocs.pm/tankerking>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
