module Wallets.Ui.Icon exposing
    ( check
    , chevronLeft
    , chevronRight
    , clock
    , cog
    , edit
    , list
    , lock
    , roundedAdd
    , wallet
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Json.Encode as Encode


create : String -> Html msg
create name =
    Html.node "wallets-ui-icon"
        [ Attributes.class "block w-full h-full"
        , Attributes.property "name" (Encode.string name)
        ]
        []



-- ICONS


check : Html msg
check =
    create "check"


lock : Html msg
lock =
    create "lock"


list : Html msg
list =
    create "list"


chevronLeft : Html msg
chevronLeft =
    create "chevron-left"


chevronRight : Html msg
chevronRight =
    create "chevron-right"


edit : Html msg
edit =
    create "edit"


clock : Html msg
clock =
    create "clock"


cog : Html msg
cog =
    create "cog"


wallet : Html msg
wallet =
    create "wallet"


roundedAdd : Html msg
roundedAdd =
    create "rounded-add"
