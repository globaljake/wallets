port module Wallets.Wallet exposing
    ( Wallet
    , available
    , budget
    , create
    , delete
    , emoji
    , id
    , index
    , indexResponse
    , mockList
    , percentAvailable
    , reloadTest
    , show
    , showResponse
    , spent
    , title
    , update
    )

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



-- TYPES


type Wallet
    = Wallet Internal


type alias Internal =
    { id : String
    , title : String
    , emoji : String
    , budget : Int
    , available : Int
    }


id : Wallet -> String
id (Wallet wallet) =
    wallet.id


title : Wallet -> String
title (Wallet wallet) =
    wallet.title


emoji : Wallet -> String
emoji (Wallet wallet) =
    wallet.emoji


budget : Wallet -> Int
budget (Wallet wallet) =
    wallet.budget


available : Wallet -> Int
available (Wallet wallet) =
    wallet.available


spent : Wallet -> Int
spent (Wallet wallet) =
    wallet.budget - wallet.available


percentAvailable : Wallet -> Float
percentAvailable (Wallet wallet) =
    toFloat wallet.available / toFloat wallet.budget * 100


mockList : List Wallet
mockList =
    [ Wallet { id = "1", title = "Shopping", emoji = "🛍", budget = 100, available = 50 }
    , Wallet { id = "2", title = "Entertainment", emoji = "🎬", budget = 50, available = 50 }
    , Wallet { id = "3", title = "Groceries", emoji = "\u{1F951}", budget = 100, available = 75 }
    , Wallet { id = "4", title = "Eating Out", emoji = "🍕", budget = 80, available = 0 }
    ]


encode : Wallet -> Encode.Value
encode (Wallet wallet) =
    Encode.object
        [ ( "id", Encode.string wallet.id )
        , ( "title", Encode.string wallet.title )
        , ( "emoji", Encode.string wallet.emoji )
        , ( "budget", Encode.int wallet.budget )
        , ( "available", Encode.int wallet.available )
        ]


decoder : Decode.Decoder Wallet
decoder =
    Decode.succeed Internal
        |> Decode.required "id" Decode.string
        |> Decode.required "title" Decode.string
        |> Decode.required "emoji" Decode.string
        |> Decode.required "budget" Decode.int
        |> Decode.required "available" Decode.int
        |> Decode.map Wallet


port walletInbound : (Encode.Value -> msg) -> Sub msg


inboundHelp : (Result String a -> msg) -> Decode.Decoder a -> Sub msg
inboundHelp tagger decoderA =
    walletInbound <|
        \value ->
            Decode.decodeValue decoderA value
                |> Result.mapError Decode.errorToString
                |> tagger


indexResponse :
    (Result String { idList : List String, wallets : Dict String Wallet } -> msg)
    -> Sub msg
indexResponse tagger =
    inboundHelp tagger
        (Decode.field "tag" Decode.string
            |> Decode.andThen
                (\tag ->
                    case tag of
                        "IndexResponse" ->
                            Decode.succeed
                                (\idList wallets ->
                                    { idList = idList, wallets = wallets }
                                )
                                |> Decode.required "idList" (Decode.list Decode.string)
                                |> Decode.required "wallets" (Decode.dict decoder)

                        _ ->
                            Decode.fail "not right tag"
                )
        )


showResponse : (Result String Wallet -> msg) -> Sub msg
showResponse tagger =
    inboundHelp tagger
        (Decode.field "tag" Decode.string
            |> Decode.andThen
                (\tag ->
                    case tag of
                        "ShowResponse" ->
                            Decode.field "wallet" decoder

                        _ ->
                            Decode.fail "not right tag"
                )
        )


port walletOutbound : Encode.Value -> Cmd msg


create :
    { title : String
    , emoji : String
    , budget : Int
    }
    -> Cmd msg
create config =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Create" )
            , ( "title", Encode.string config.title )
            , ( "emoji", Encode.string config.emoji )
            , ( "budget", Encode.int config.budget )
            , ( "available", Encode.int config.budget )
            ]


index : Cmd msg
index =
    walletOutbound <| Encode.object [ ( "tag", Encode.string "Index" ) ]


show : String -> Cmd msg
show id_ =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Show" )
            , ( "id", Encode.string id_ )
            ]


reloadTest : Cmd msg
reloadTest =
    walletOutbound <| Encode.object [ ( "tag", Encode.string "ReloadTest" ) ]


update : { id : String, amount : Int } -> Cmd msg
update config =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Update" )
            , ( "id", Encode.string config.id )
            , ( "amount", Encode.int config.amount )
            ]


delete : String -> Cmd msg
delete id_ =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Delete" )
            , ( "id", Encode.string id_ )
            ]
