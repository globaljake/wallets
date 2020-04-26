module Wallets.Ui.PullToRefresh exposing (Config, view)

import Html exposing (Html)
import Html.Attributes as Attributes


type alias Config msg =
    { onRefresh : msg
    , content : Html msg
    }


view : Config msg -> Html msg
view config =
    Html.node "wallets-ui-pull-to-refresh" [ Attributes.class "flex bg-blue-300" ] [ config.content ]
