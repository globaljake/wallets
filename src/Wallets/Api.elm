module Wallets.Api exposing (delete, get, local, post, put)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task exposing (Task)
import Wallets.Api.Endpoint as Endpoint exposing (Endpoint)


local :
    { url : String
    , payload : Maybe Encode.Value
    , decoder : Decode.Decoder a
    }
    -> Task Http.Error a
local { url, payload, decoder } =
    Http.task
        { method = "GET"
        , headers = []
        , url = "localrequest/" ++ url
        , body = Http.jsonBody (Maybe.withDefault Encode.null payload)
        , resolver = jsonResolver decoder
        , timeout = Nothing
        }


get : Endpoint -> Decode.Decoder a -> Task Http.Error a
get endpoint decoder =
    Endpoint.task
        { method = "GET"
        , headers = []
        , endpoint = endpoint
        , body = Http.emptyBody
        , decoder = decoder
        , timeout = Nothing
        }


put : Endpoint -> Http.Body -> Decode.Decoder a -> Task Http.Error a
put endpoint body decoder =
    Endpoint.task
        { method = "PUT"
        , headers = []
        , endpoint = endpoint
        , body = body
        , decoder = decoder
        , timeout = Nothing
        }


post : Endpoint -> Http.Body -> Decode.Decoder a -> Task Http.Error a
post endpoint body decoder =
    Endpoint.task
        { method = "POST"
        , headers = []
        , endpoint = endpoint
        , body = body
        , decoder = decoder
        , timeout = Nothing
        }


delete : Endpoint -> Http.Body -> Decode.Decoder a -> Task Http.Error a
delete endpoint body decoder =
    Endpoint.task
        { method = "DELETE"
        , headers = []
        , endpoint = endpoint
        , body = body
        , decoder = decoder
        , timeout = Nothing
        }


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
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (Decode.errorToString err))
