module Web.Api exposing (local)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task exposing (Task)


local :
    { url : String
    , payload : Maybe Encode.Value
    , decoder : Decode.Decoder a
    }
    -> Task String a
local { url, payload, decoder } =
    Http.task
        { method = "POST"
        , headers = []
        , url = "localrequest/" ++ url
        , body = Http.jsonBody (Maybe.withDefault Encode.null payload)
        , resolver = jsonResolver decoder
        , timeout = Nothing
        }


jsonResolver : Decode.Decoder a -> Http.Resolver String a
jsonResolver decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.GoodStatus_ _ body ->
                    Decode.decodeString (Decode.field "data" decoder) body
                        |> Result.mapError
                            (\e ->
                                "Decode Http Body Error:" ++ Decode.errorToString e
                            )

                _ ->
                    Err "Http Error"
