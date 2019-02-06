module Ui.Modal exposing (display)

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Json.Encode as Encode


type alias Config msg =
    { body : Html msg
    , onClose : msg
    }


display : Config msg -> Html msg
display config =
    Html.node "wallets-ui-modal"
        [ Attributes.class "absolute bg-grey-light pin UiModal-animation UiModal-slideInUp" ]
        [ config.body
        ]
