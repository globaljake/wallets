port module Ui.Transition exposing (Direction(..), container, setup, start, subscription)

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Json.Encode as Encode exposing (Value)
import Url exposing (Url)


port uiTransitionSetup : { url : String, direction : Maybe String } -> Cmd msg


setup : Url -> Maybe Direction -> Cmd msg
setup url direction =
    uiTransitionSetup <|
        { url = Url.toString url
        , direction = Maybe.map directionToString direction
        }


type Direction
    = Left
    | Right


directionToString : Direction -> String
directionToString direction =
    case direction of
        Left ->
            "left"

        Right ->
            "right"


port uiTransitionStart : () -> Cmd msg


start : Cmd msg
start =
    uiTransitionStart ()


port uiTransitionIsSet : (String -> msg) -> Sub msg


subscription : (String -> msg) -> Sub msg
subscription =
    uiTransitionIsSet


type alias Config msg =
    { content : Html msg }


container : Config msg -> Html msg
container config =
    Html.node "wallets-ui-transition"
        [ Attributes.class "block relative w-full h-full" ]
        [ Html.div [ Attributes.class "h-full w-full" ] [ config.content ]
        ]
