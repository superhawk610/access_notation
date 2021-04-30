import gleam/list
import gleam/int
import gleam/iterator as iter
import gleam/string as str
import gleam/bit_string as bstr

pub type Accessor {
  Key(String)
  At(Int)
}

pub fn parse(input: String) -> Result(List(Accessor), String) {
  let resp =
    input
    |> bstr.from_string()
    |> do_parse([Text(bstr.from_string(""))])
  
  case resp {
    Ok(keys) -> {
      let keys =
        keys
        |> iter.from_list()
        |> iter.map(fn (x) {
          case x {
            Text(bstr) -> Key(bstr_to_str(bstr))
            Int(index) -> At(index)
          }
        })
        |> iter.to_list()

      Ok(keys)
    }

    Error(reason) ->
      Error(reason)
  }
}

type AccElement {
  Text(BitString)
  Int(Int)
  ParseKey(BitString)
  ParseAt(BitString)
}

// TODO: switch to StringBuilder for combining characters
fn do_parse(input: BitString, acc: List(AccElement)) -> Result(List(AccElement), String) {
  case input, acc {
    <<"":utf8>>, [Text(<<"":utf8>>)] ->
      Error("empty input")
    <<"":utf8>>, [ParseAt(_), .._] ->
      Error("missing closing array bracket")
    <<"":utf8>>, acc ->
      Ok(list.reverse(acc))
    <<"[":utf8, _:binary>>, [Text(<<"":utf8>>)] ->
      Error("must provide a prefix key before array brackets")
    <<"[":utf8, rest:binary>>, acc ->
      do_parse(rest, [ParseAt(bstr.from_string("")), ..acc])
    <<"]":utf8, _:binary>>, [ParseAt(<<"":utf8>>), .._] ->
      Error("empty array brackets ([]) are not allowed")
    <<"]":utf8, rest:binary>>, [ParseAt(parsing), ..acc] ->
      case int.parse(bstr_to_str(parsing)) {
        Ok(index) -> do_parse(rest, [Int(index), ..acc])
        Error(_) -> Error(str.append("invalid array index: ", bstr_to_str(parsing)))
      }
    <<"]":utf8, _:binary>>, _ ->
      Error("unexpected closing bracket")
    <<char:utf8_codepoint, rest:binary>>, [ParseAt(parsing), ..acc] ->
      do_parse(rest, [ParseAt(<<parsing:bit_string, char:utf8_codepoint>>), ..acc])
    <<char:utf8_codepoint, rest:binary>>, [Text(prefix), ..acc] ->
      do_parse(rest, [Text(<<prefix:bit_string, char:utf8_codepoint>>), ..acc])
  }
}

fn bstr_to_str(bs: BitString) -> String {
  assert Ok(str) = bstr.to_string(bs)
  str
}
