module Examples.Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, button, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Wallets.Ui.Button as Button


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Examples"
    , body =
        [ Html.div [ Attributes.class "container py-8" ]
            [ Html.div [ Attributes.class "flex" ]
                [ Button.primary
                    { onClick = NoOp
                    , label = "Example Text"
                    }
                , Button.gray
                    { onClick = NoOp
                    , label = "Example Text"
                    }
                ]
            ]
        ]
    }


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
