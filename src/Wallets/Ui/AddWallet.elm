module Wallets.Ui.AddWallet exposing (Ext(..), Model, Msg(..), init, update, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


type Model
    = Model
        { emojiField : String
        , titleField : String
        , budgetField : String
        }


type Msg
    = EmojiFieldEntered String
    | TitleFieldEntered String
    | BudgetFieldEntered String
    | Submit


type Ext
    = RequestSubmit { emoji : String, title : String, budget : Int }
    | NoOp


init : Model
init =
    Model
        -- { emojiField = "🛍"
        -- , titleField = "Shopping"
        -- , budgetField = "100"
        -- }
        { emojiField = ""
        , titleField = ""
        , budgetField = ""
        }


view : Model -> Html Msg
view (Model model) =
    Html.div []
        [ Html.div [ Attributes.class "my-2 w-full" ]
            [ Html.input
                [ Attributes.class "w-full p-1"
                , Attributes.value model.emojiField
                , Attributes.placeholder "Emoji"
                , Events.onInput EmojiFieldEntered
                ]
                []
            ]
        , Html.div [ Attributes.class "my-2 w-full" ]
            [ Html.input
                [ Attributes.class "w-full p-1"
                , Attributes.value model.titleField
                , Attributes.placeholder "Title"
                , Events.onInput TitleFieldEntered
                ]
                []
            ]
        , Html.div [ Attributes.class "my-2 w-full" ]
            [ Html.input
                [ Attributes.class "w-full p-1"
                , Attributes.value model.budgetField
                , Attributes.placeholder "Budget"
                , Events.onInput BudgetFieldEntered
                ]
                []
            ]
        , Html.button [ Events.onClick Submit ]
            [ Html.text "Create Wallet"
            ]
        ]


update : Msg -> Model -> ( Model, Ext )
update msg (Model model) =
    case msg of
        EmojiFieldEntered text ->
            ( Model { model | emojiField = text }, NoOp )

        TitleFieldEntered text ->
            ( Model { model | titleField = text }, NoOp )

        BudgetFieldEntered text ->
            ( Model { model | budgetField = text }, NoOp )

        Submit ->
            ( Model model
            , RequestSubmit
                { emoji = model.emojiField
                , title = model.titleField
                , budget =
                    String.toFloat model.budgetField
                        |> Maybe.map (truncate << (*) 100)
                        |> Maybe.withDefault 0
                }
            )
