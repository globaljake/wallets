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
    , spent
    , title
    , update
    )

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
    , budget : Float
    , available : Float
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


budget : Wallet -> Float
budget (Wallet wallet) =
    wallet.budget


available : Wallet -> Float
available (Wallet wallet) =
    wallet.available


spent : Wallet -> Float
spent (Wallet wallet) =
    wallet.budget - wallet.available


percentAvailable : Wallet -> Float
percentAvailable (Wallet wallet) =
    wallet.available / wallet.budget * 100


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
        , ( "budget", Encode.float wallet.budget )
        , ( "available", Encode.float wallet.available )
        ]


decoder : Decode.Decoder Wallet
decoder =
    Decode.succeed Internal
        |> Decode.required "id" Decode.string
        |> Decode.required "title" Decode.string
        |> Decode.required "emoji" Decode.string
        |> Decode.required "budget" Decode.float
        |> Decode.required "available" Decode.float
        |> Decode.map Wallet


port walletInbound : (Encode.Value -> msg) -> Sub msg


indexResponse : (Result String (List Wallet) -> msg) -> Sub msg
indexResponse tagger =
    let
        d =
            Decode.field "tag" Decode.string
                |> Decode.andThen
                    (\tag ->
                        case tag of
                            "IndexResponse" ->
                                Decode.field "wallets" (Decode.list decoder)

                            _ ->
                                Decode.fail "not right tag"
                    )
    in
    walletInbound <|
        \value ->
            Decode.decodeValue d value
                |> Result.mapError Decode.errorToString
                |> tagger


port walletOutbound : Encode.Value -> Cmd msg


create :
    { title : String
    , emoji : String
    , budget : Float
    }
    -> Cmd msg
create config =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Create" )
            , ( "title", Encode.string config.title )
            , ( "emoji", Encode.string config.emoji )
            , ( "budget", Encode.float config.budget )
            , ( "available", Encode.float config.budget )
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


update : { id : String, amount : Float } -> Cmd msg
update config =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Update" )
            , ( "id", Encode.string config.id )
            , ( "amount", Encode.float config.amount )
            ]


delete : String -> Cmd msg
delete id_ =
    walletOutbound <|
        Encode.object
            [ ( "tag", Encode.string "Delete" )
            , ( "id", Encode.string id_ )
            ]
