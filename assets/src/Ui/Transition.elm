port module Ui.Transition exposing (Direction(..), container, setup, start, subscription)

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Json.Encode as Encode exposing (Value)
import Url exposing (Url)


type Direction
    = Left
    | Right


type alias Config msg =
    { content : Html msg }


port uiTransitionSetup : { url : String, direction : String } -> Cmd msg


port uiTransitionStart : () -> Cmd msg


port uiTransitionIsSet : (String -> msg) -> Sub msg


subscription : (String -> msg) -> Sub msg
subscription =
    uiTransitionIsSet


start : Cmd msg
start =
    uiTransitionStart ()


setup : Url -> Direction -> Cmd msg
setup url direction =
    uiTransitionSetup <|
        { url = Url.toString url
        , direction =
            case direction of
                Left ->
                    "left"

                Right ->
                    "right"
        }


container : Config msg -> Html msg
container config =
    Html.node "wallets-ui-transition"
        [ Attributes.class "block relative w-full h-full" ]
        [ Html.div [ Attributes.class "h-full w-full" ] [ config.content ]
        ]
