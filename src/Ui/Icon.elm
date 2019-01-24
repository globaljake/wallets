module Ui.Icon exposing (Icon(..), view, viewDecorative)

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Json.Encode as Encode


type Icon
    = Check
    | Lock
    | List
    | ChevronLeft
    | ChevronRight


view : { alt : String, icon : Icon } -> Html msg
view config =
    Html.node "ui-rollover-icon" [ iconName config.icon, iconTitle config.alt ] []


viewDecorative : Icon -> Html msg
viewDecorative icon =
    Html.node "ui-rollover-icon" [ iconName icon ] []



-- INTERNAL --


iconName : Icon -> Attribute msg
iconName =
    Attributes.property "iconName" << Encode.string << toString


iconTitle : String -> Attribute msg
iconTitle =
    Attributes.property "iconTitle" << Encode.string


toString : Icon -> String
toString icon =
    case icon of
        Check ->
            "check"

        Lock ->
            "lock"

        List ->
            "list"

        ChevronLeft ->
            "chevron-left"

        ChevronRight ->
            "chevron-right"
