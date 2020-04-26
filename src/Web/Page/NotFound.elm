module Web.Page.NotFound exposing (view)

import Html exposing (Html)
import Html.Attributes as Attributes



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "404 Not Found"
    , content =
        Html.h1 [ Attributes.class "text-xl" ]
            [ Html.text "404 Not Found"
            ]
    }
