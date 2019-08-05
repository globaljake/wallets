module Wallets.Ui.Spend exposing (Ext(..), Model, Msg(..), init, update, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Wallets.Wallet as Wallet exposing (Wallet)


type Model
    = Model
        { wallet : Wallet
        , amountField : String
        , descriptionField : String
        }


type Msg
    = AmountFieldEntered String
    | DescriptionFieldEntered String
    | Submit


type Ext
    = RequestSubmit { walletId : String, description : String, amount : Int }
    | NoOp


init : Wallet -> Model
init wallet =
    Model
        { wallet = wallet
        , amountField = ""
        , descriptionField = ""
        }


view : Model -> Html Msg
view (Model model) =
    Html.div [ Attributes.class "flex flex-col" ]
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
        , Html.div
            [ Attributes.class "mb-4 w-full" ]
            [ Html.input
                [ Attributes.class "w-full p-2 border rounded"
                , Attributes.value model.descriptionField
                , Attributes.placeholder "Description"
                , Events.onInput DescriptionFieldEntered
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


update : Msg -> Model -> ( Model, Ext )
update msg (Model model) =
    case msg of
        AmountFieldEntered text ->
            ( Model { model | amountField = text }, NoOp )

        DescriptionFieldEntered text ->
            ( Model { model | descriptionField = text }, NoOp )

        Submit ->
            ( Model model
            , RequestSubmit
                { walletId = Wallet.id model.wallet
                , description = model.descriptionField
                , amount =
                    String.toFloat model.amountField
                        |> Maybe.map (truncate << (*) 100)
                        |> Maybe.withDefault 0
                }
            )
