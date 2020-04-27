module Wallets.Wallet exposing
    ( Wallet
    , available
    , budget
    , create
    , decoder
    , delete
    , emoji
    , id
    , index
    , name
    , percentAvailable
    , show
    , spent
    )

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Task exposing (Task)
import Wallets.Api as Api
import Wallets.Api.Endpoint as Endpoint
import Wallets.WalletId as WalletId exposing (WalletId)



-- TYPES


type Wallet
    = Wallet Internal


type alias Internal =
    { id : WalletId
    , name : String
    , emoji : String
    , budget : Int

    -- , available : Int
    }



-- INFO


id : Wallet -> WalletId
id (Wallet wallet) =
    wallet.id


name : Wallet -> String
name (Wallet wallet) =
    wallet.name


emoji : Wallet -> String
emoji (Wallet wallet) =
    wallet.emoji


budget : Wallet -> Int
budget (Wallet wallet) =
    wallet.budget


available : Wallet -> Int
available (Wallet wallet) =
    -- wallet.available
    0


spent : Wallet -> Int
spent (Wallet wallet) =
    -- wallet.budget - wallet.available
    0


percentAvailable : Wallet -> Float
percentAvailable (Wallet wallet) =
    -- toFloat wallet.available / toFloat wallet.budget * 100
    0



-- SERIALIZATION


encode : Wallet -> Encode.Value
encode (Wallet wallet) =
    Encode.object
        [ ( "id", WalletId.encode wallet.id )
        , ( "name", Encode.string wallet.name )
        , ( "emoji", Encode.string wallet.emoji )
        , ( "budget", Encode.int wallet.budget )

        -- , ( "available", Encode.int wallet.available )
        ]


decoder : Decode.Decoder Wallet
decoder =
    Decode.succeed Internal
        |> Decode.required "id" WalletId.decoder
        |> Decode.required "name" Decode.string
        |> Decode.required "emoji" Decode.string
        |> Decode.required "budget" Decode.int
        -- |> Decode.required "available" Decode.int
        |> Decode.map Wallet



-- API


create : { title : String, emoji : String, budget : Int } -> Task Http.Error Wallet
create config =
    Api.post Endpoint.wallets
        (Http.jsonBody <|
            Encode.object
                [ ( "title", Encode.string config.title )
                , ( "emoji", Encode.string config.emoji )
                , ( "budget", Encode.int config.budget )
                , ( "available", Encode.int config.budget )
                ]
        )
        decoder


index : Task Http.Error { feed : List String, wallets : Dict String Wallet }
index =
    Api.get Endpoint.wallets
        (Decode.succeed
            (\feed wallets -> { feed = feed, wallets = wallets })
            |> Decode.required "feed" (Decode.list (Decode.oneOf [ Decode.string, Decode.map String.fromInt Decode.int ]))
            |> Decode.required "wallets" (Decode.dict decoder)
        )


show : WalletId -> Task Http.Error Wallet
show walletId =
    Api.get (Endpoint.wallet walletId) decoder


delete : WalletId -> Task Http.Error WalletId
delete walletId =
    Api.delete (Endpoint.wallet walletId)
        (Http.jsonBody <|
            Encode.object [ ( "id", WalletId.encode walletId ) ]
        )
        (Decode.field "id" WalletId.decoder)
