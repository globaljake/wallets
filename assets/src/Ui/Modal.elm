module Ui.Modal exposing (view)

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Json.Encode as Encode


view : Html msg -> Html msg
view content =
    Html.node "wallets-ui-modal"
        [ Attributes.class "absolute bg-grey-light pin UiModal-animation UiModal-slideInUp" ]
        [ content
        ]
