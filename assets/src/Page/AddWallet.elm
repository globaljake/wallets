module Page.AddWallet exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Session exposing (Session)
import Task exposing (Task)
import Ui.Icon as Icon



-- MODEL


type alias Model =
    {}


init : Session -> ( Model, Cmd Msg )
init session =
    ( {}, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div [ Attributes.class "w-full h-full" ]
        [ Html.div [ Attributes.class "flex h-full flex-col" ]
            [ Html.div [ Attributes.class "flex items-end h-10 justify-between" ]
                [ Html.button
                    [ Attributes.class "w-8 h-8 border-2 border-white rounded-full"
                    , Attributes.style "background-image" "url(https://github.com/globaljake.png)"
                    , Attributes.style "background-size" "contain"
                    ]
                    []
                , Html.button
                    [ Attributes.class "text-gray-dark rounded-full px-4 py-2"
                    , Attributes.style "background-color" "rgba(255,255,255,.1)"
                    ]
                    [ Html.text "$200.00" ]
                , Html.button [ Attributes.class "w-8 h-8 text-gray-dark" ]
                    [ Icon.view { alt = "categories", icon = Icon.List }
                    ]
                ]
            , Html.div [ Attributes.class "flex flex-1 justify-center items-center my-8" ]
                [ Html.div [ Attributes.class "flex justify-center text-gray-dark" ]
                    [ Html.span
                        [ Attributes.class "-ml-6"
                        , Attributes.style "font-size" "4.5rem"
                        ]
                        [ Html.text "$" ]
                    , Html.span
                        [ Attributes.class "-mt-6 font-light"
                        , Attributes.style "font-size" "10rem"
                        ]
                        [ Html.text "0" ]
                    ]
                ]
            , Html.div [ Attributes.class "flex flex-wrap" ]
                [ keyPadButton "1"
                , keyPadButton "2"
                , keyPadButton "3"
                , keyPadButton "4"
                , keyPadButton "5"
                , keyPadButton "6"
                , keyPadButton "7"
                , keyPadButton "8"
                , keyPadButton "9"
                , keyPadButton "."
                , keyPadButton "0"
                , keyPadButton "<"
                ]
            , Html.div
                [ Attributes.class "flex my-6" ]
                [ Html.div [ Attributes.class "w-full" ]
                    [ Html.button
                        [ Attributes.class "p-5 rounded-lg w-full"
                        , Attributes.style "background-color" "rgba(255,255,255,.1)"
                        ]
                        [ Html.span [ Attributes.class "text-gray-dark font-medium text-xl" ]
                            [ Html.text "Budget"
                            ]
                        ]
                    ]
                ]
            ]
        ]


keyPadButton : String -> Html msg
keyPadButton label =
    Html.div [ Attributes.class "w-1/3" ]
        [ Html.button [ Attributes.class "p-5 w-full" ]
            [ Html.span [ Attributes.class "text-gray-dark text-2xl" ] [ Html.text label ]
            ]
        ]



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
