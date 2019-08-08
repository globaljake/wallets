port module Wallets.Wallet exposing
    ( Wallet
    , available
    , budget
    , create
    , decoder
    , delete
    , emoji
    , id
    , index
    , mockList
    , percentAvailable
    , show
    , spent
    , title
    )

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Task exposing (Task)
import Web.Api as Api



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


create : { title : String, emoji : String, budget : Int } -> Task String Wallet
create config =
    Api.local
        { url = "wallet/create"
        , payload =
            Just <|
                Encode.object
                    [ ( "title", Encode.string config.title )
                    , ( "emoji", Encode.string config.emoji )
                    , ( "budget", Encode.int config.budget )
                    , ( "available", Encode.int config.budget )
                    ]
        , decoder = Decode.field "wallet" decoder
        }


index : Task String { feed : List String, wallets : Dict String Wallet }
index =
    Api.local
        { url = "wallet/index"
        , payload = Nothing
        , decoder =
            Decode.succeed
                (\feed wallets -> { feed = feed, wallets = wallets })
                |> Decode.required "feed" (Decode.list Decode.string)
                |> Decode.required "wallets" (Decode.dict decoder)
        }


show : String -> Task String Wallet
show id_ =
    Api.local
        { url = "wallet/show"
        , payload = Just <| Encode.object [ ( "id", Encode.string id_ ) ]
        , decoder = Decode.field "wallet" decoder
        }


delete : String -> Task String String
delete id_ =
    Api.local
        { url = "wallet/delete_"
        , payload = Just <| Encode.object [ ( "id", Encode.string id_ ) ]
        , decoder = Decode.field "id" Decode.string
        }
