module Wallets.Ui.Spend exposing (Ext(..), Model, Msg(..), init, update, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Wallets.Wallet as Wallet exposing (Wallet)


type Model
    = Model
        { wallet : Wallet
        , amountField : String
        }


type Msg
    = AmountFieldEntered String
    | DeleteWallet
    | Submit


type Ext
    = RequestSubmit { id : String, amount : Int }
    | RequestDelete String
    | NoOp


init : Wallet -> Model
init wallet =
    Model
        { wallet = wallet
        , amountField = ""
        }


view : Model -> Html Msg
view (Model model) =
    Html.div [ Attributes.class "flex flex-col h-full justify-between" ]
        [ Html.div [ Attributes.class "flex flex-col" ]
            [ Html.div
                [ Attributes.class "mb-4 w-full" ]
                [ Html.input
                    [ Attributes.class "w-full p-2 border rounded"
                    , Attributes.value model.amountField
                    , Attributes.placeholder "Amount"
                    , Events.onInput AmountFieldEntered
                    ]
                    []
                ]
            , Html.button
                [ Attributes.class "p-4 bg-green-400 rounded font-semibold text-white"
                , Events.onClick Submit
                ]
                [ Html.text "Spend"
                ]
            ]
        , Html.button
            [ Attributes.class "mt-6 p-4 font-semibold text-red-600"
            , Events.onClick <| DeleteWallet
            ]
            [ Html.text "Delete"
            ]
        ]


update : Msg -> Model -> ( Model, Ext )
update msg (Model model) =
    case msg of
        AmountFieldEntered text ->
            ( Model { model | amountField = text }, NoOp )

        DeleteWallet ->
            ( Model model, RequestDelete (Wallet.id model.wallet) )

        Submit ->
            ( Model model
            , RequestSubmit
                { id = Wallet.id model.wallet
                , amount =
                    String.toFloat model.amountField
                        |> Maybe.map (truncate << (*) 100)
                        |> Maybe.withDefault 0
                }
            )