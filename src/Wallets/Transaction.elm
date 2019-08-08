port module Wallets.Transaction exposing
    ( Transaction
    , amount
    , create
    , description
    , id
    , index
    , indexByWalletId
    , walletId
    )

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Task exposing (Task)
import Web.Api as Api



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


create : { walletId : String, amount : Int, description : String } -> Task String Transaction
create config =
    Api.local
        { url = "transaction/create"
        , payload =
            Just <|
                Encode.object
                    [ ( "walletId", Encode.string config.walletId )
                    , ( "amount", Encode.int config.amount )
                    , ( "description", Encode.string config.description )
                    ]
        , decoder = Decode.field "transaction" decoder
        }


index : Task String { feed : List String, transactions : Dict String Transaction }
index =
    Api.local
        { url = "transaction/index"
        , payload = Nothing
        , decoder =
            Decode.succeed
                (\feed transactions -> { feed = feed, transactions = transactions })
                |> Decode.required "feed" (Decode.list Decode.string)
                |> Decode.required "transactions" (Decode.dict decoder)
        }


indexByWalletId : String -> Task String { feed : List String, transactions : Dict String Transaction }
indexByWalletId walletId_ =
    Api.local
        { url = "transaction/indexByWalletId"
        , payload = Just <| Encode.object [ ( "walletId", Encode.string walletId_ ) ]
        , decoder =
            Decode.succeed
                (\feed transactions -> { feed = feed, transactions = transactions })
                |> Decode.required "feed" (Decode.list Decode.string)
                |> Decode.required "transactions" (Decode.dict decoder)
        }


show : String -> Task String Transaction
show id_ =
    Api.local
        { url = "transaction/show"
        , payload = Just <| Encode.object [ ( "id", Encode.string id_ ) ]
        , decoder = Decode.field "transaction" decoder
        }


delete : String -> Task String String
delete id_ =
    Api.local
        { url = "transaction/delete_"
        , payload = Just <| Encode.object [ ( "id", Encode.string id_ ) ]
        , decoder = Decode.field "id" Decode.string
        }
