module Wallets.Ui.Button exposing (gray, primary)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


type alias Config msg =
    { onClick : msg
    , label : String
    }


buttonClass : String
buttonClass =
    "px-5 py-3 inline-block rounded-lg font-semibold tracking-wide uppercase"


primary : Config msg -> Html msg
primary { label, onClick } =
    Html.button
        [ Events.onClick onClick
        , Attributes.classList
            [ ( buttonClass, True )
            , ( "bg-indigo-500 hover:bg-indigo-400 text-white shadow-lg", True )
            ]
        ]
        [ Html.text label ]


gray : Config msg -> Html msg
gray { label, onClick } =
    Html.button
        [ Events.onClick onClick
        , Attributes.classList
            [ ( buttonClass, True )
            , ( "bg-gray-500 hover:bg-gray-400 text-gray-900", True )
            ]
        ]
        [ Html.text label ]
