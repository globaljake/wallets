module Web.Page exposing (view)

import Browser exposing (Document)
import Html exposing (Html)
import Html.Attributes as Attributes
import Web.Route as Route exposing (Route)


view : { title : String, content : Html msg } -> Document msg
view { title, content } =
    { title = title ++ " - Ship"
    , body = [ viewContent content ]
    }


viewContent : Html msg -> Html msg
viewContent content =
    Html.div [ Attributes.class "container h-full" ]
        [ content
        ]
