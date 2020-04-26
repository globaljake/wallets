module Wallets.WalletId exposing (WalletId, decoder, encode, parser, toString)

import Json.Decode as Decode
import Json.Encode as Encode
import Url.Parser as Parser


type WalletId
    = WalletId String


encode : WalletId -> Encode.Value
encode (WalletId walletId) =
    Encode.string walletId


decoder : Decode.Decoder WalletId
decoder =
    Decode.map WalletId (Decode.oneOf [ Decode.string, Decode.map String.fromInt Decode.int ])


parser : Parser.Parser (WalletId -> a) a
parser =
    Parser.map WalletId Parser.string



-- queryParser : String -> Query.Parser (Maybe PostId)
-- queryParser s =
--     Query.map (Maybe.map PostId) (Query.uuidString s)


toString : WalletId -> String
toString (WalletId walletId) =
    walletId
