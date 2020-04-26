module Wallets.Api.Endpoint exposing (Endpoint, task, transactions, wallet, wallets)

import Http
import Json.Decode as Decode exposing (Decoder)
import Task exposing (Task)
import Url.Builder exposing (QueryParameter)
import Wallets.WalletId as WalletId exposing (WalletId)


type Endpoint
    = Endpoint String


task :
    { method : String
    , headers : List Http.Header
    , endpoint : Endpoint
    , body : Http.Body
    , decoder : Decoder a
    , timeout : Maybe Float
    }
    -> Task Http.Error a
task config =
    Http.task
        { method = config.method
        , headers = config.headers
        , url = unwrap config.endpoint
        , body = config.body
        , resolver = jsonResolver config.decoder
        , timeout = config.timeout
        }


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


jsonResolver : Decode.Decoder a -> Http.Resolver Http.Error a
jsonResolver decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ badUrl ->
                    Err (Http.BadUrl badUrl)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString (Decode.field "data" decoder) body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (Decode.errorToString err))


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Endpoint (Url.Builder.crossOrigin "http://localhost:4000" ("api" :: paths) queryParams)



-- ENDPOINTS


wallets : Endpoint
wallets =
    url [ "wallets" ] []


wallet : WalletId -> Endpoint
wallet walletId =
    url [ "wallets", WalletId.toString walletId ] []


transactions : WalletId -> Endpoint
transactions walletId =
    url [ "wallets", WalletId.toString walletId, "transactions" ] []



-- transaction : WalletId -> TransactionId -> Endpoint
-- transaction walletId transactionId =
--     url
--         [ "wallets"
--         , WalletId.toString walletId
--         , "transactions" TransactionId.toString transactionId
--         ]
--         []
