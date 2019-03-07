module Page exposing (Page(..), view)

import Api exposing (Cred)
import Avatar
import Browser exposing (Document)
import Constants
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Encode exposing (Value)
import Route exposing (Route)
import Session exposing (Session)
import Ui.IconInjector as IconInjector
import Ui.Transition as Transition
import Username exposing (Username)
import Viewer exposing (Viewer)


type Page
    = Other
    | Home
    | Profile
    | Login
    | Register


view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Wallets"
    , body =
        [ Html.main_
            [ Attributes.class "h-full text-grey-dark font-sans bg-grey-light flex justify-center "
            ]
            [ IconInjector.view
            , Html.div [ Attributes.class "w-full h-full sm:hidden" ]
                [ Transition.container { content = content }
                ]
            ]
        ]
    }
