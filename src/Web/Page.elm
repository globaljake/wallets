module Web.Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html)
import Html.Attributes as Attributes
import Web.Route as Route exposing (Route)


type Page
    = Other
    | Home


view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
    { title = title ++ " - Ship"
    , body =
        [ viewContent content
        ]
    }


viewHeader : Page -> Html msg
viewHeader page =
    Html.nav [ Attributes.class "container" ] []


viewContent : Html msg -> Html msg
viewContent content =
    Html.div [ Attributes.class "container h-full" ]
        [ content
        ]


viewFooter : Html msg
viewFooter =
    Html.footer [ Attributes.class "container" ] []


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        _ ->
            False
