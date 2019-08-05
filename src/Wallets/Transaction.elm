port module Wallets.Transaction exposing
    ( Transaction
    , amount
    , create
    , description
    , id
    , inbound
    , index
    , walletId
    )

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- TYPES


type Transaction
    = Transaction Internal


type alias Internal =
    { id : String
    , walletId : String
    , description : String
    , amount : Int
    }


id : Transaction -> String
id (Transaction transaction) =
    transaction.id


walletId : Transaction -> String
walletId (Transaction transaction) =
    transaction.walletId


description : Transaction -> String
description (Transaction transaction) =
    transaction.description


amount : Transaction -> Int
amount (Transaction transaction) =
    transaction.amount


encode : Transaction -> Encode.Value
encode (Transaction transaction) =
    Encode.object
        [ ( "id", Encode.string transaction.id )
        , ( "walletId", Encode.string transaction.walletId )
        , ( "description", Encode.string transaction.description )
        , ( "amount", Encode.int transaction.amount )
        ]


decoder : Decode.Decoder Transaction
decoder =
    Decode.succeed Internal
        |> Decode.required "id" Decode.string
        |> Decode.required "walletId" Decode.string
        |> Decode.required "description" Decode.string
        |> Decode.required "amount" Decode.int
        |> Decode.map Transaction


port transactionInbound : (Encode.Value -> msg) -> Sub msg


inbound :
    { onIndex : Maybe (Result String { idList : List String, transactions : Dict String Transaction } -> msg)
    , onShow : Maybe (Result String Transaction -> msg)
    , onError : String -> msg
    }
    -> Sub msg
inbound config =
    let
        decoder_ =
            Decode.field "tag" Decode.string
                |> Decode.andThen
                    (\tag ->
                        case tag of
                            "IndexResponse" ->
                                Decode.succeed
                                    (\idList transactions ->
                                        case config.onIndex of
                                            Just tagger ->
                                                tagger
                                                    (Ok
                                                        { idList = idList
                                                        , transactions = transactions
                                                        }
                                                    )

                                            Nothing ->
                                                config.onError "No msg given for IndexResponse"
                                    )
                                    |> Decode.required "idList" (Decode.list Decode.string)
                                    |> Decode.required "transactions" (Decode.dict decoder)

                            "ShowResponse" ->
                                Decode.succeed
                                    (\transaction ->
                                        case config.onShow of
                                            Just tagger ->
                                                tagger (Ok transaction)

                                            Nothing ->
                                                config.onError "No msg given for ShowResponse"
                                    )
                                    |> Decode.required "transaction" decoder

                            e ->
                                Decode.fail ("Cannot decode tag of " ++ e)
                    )
    in
    transactionInbound <|
        \value ->
            case Decode.decodeValue decoder_ value of
                Ok msg ->
                    msg

                Err e ->
                    config.onError (Decode.errorToString e)


port transactionOutbound : Encode.Value -> Cmd msg


create :
    { walletId : String
    , description : String
    , amount : Int
    }
    -> Cmd msg
create config =
    transactionOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Create" )
            , ( "walletId", Encode.string config.walletId )
            , ( "description", Encode.string config.description )
            , ( "amount", Encode.int config.amount )
            ]


index : Cmd msg
index =
    transactionOutbound <| Encode.object [ ( "tag", Encode.string "Index" ) ]
