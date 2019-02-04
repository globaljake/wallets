module Page exposing (Page(..), view)

import Api exposing (Cred)
import Avatar
import Browser exposing (Document)
import Constants
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Route exposing (Route)
import Session exposing (Session)
import Ui.IconInjector as IconInjector
import Username exposing (Username)
import Viewer exposing (Viewer)


type Page
    = Other
    | Home
    | Login
    | Register


view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Wallets"
    , body =
        [ IconInjector.view
        , Html.div
            [ Attributes.class "h-full text-grey-dark font-sans bg-grey-light flex justify-center overflow-y-auto scrolling-touch"
            ]
            [ Html.div [ Attributes.class "max-w-xs w-full sm:flex hidden flex-col items-center" ]
                [ Html.text "desktop"
                ]
            , Html.div [ Attributes.class "w-full h-full sm:hidden" ] [ content ]
            ]
        ]
    }
