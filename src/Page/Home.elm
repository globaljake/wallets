module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Browser.Dom as Dom
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Loading
import Log
import Page
import PaginatedList exposing (PaginatedList)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Ui.Icon as Icon
import Url.Builder
import Username exposing (Username)



-- MODEL


type alias Model =
    { session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content =
        Html.div [ Attributes.class "w-full h-full p-4" ]
            [ Html.div [ Attributes.class "flex flex-col" ]
                [ Html.div [ Attributes.class "flex justify-between items-center" ]
                    [ Html.button
                        [ Attributes.class "w-6 h-6 border-2 border-white rounded-full"
                        , Attributes.style "background-image" "url(https://github.com/globaljake.png)"
                        , Attributes.style "background-size" "contain"
                        ]
                        []
                    , Html.button
                        [ Attributes.class "text-white text-xs rounded-full p-2"
                        , Attributes.style "background-color" "rgba(255,255,255,.1)"
                        ]
                        [ Html.text "Monthly Budget" ]
                    , Html.button [ Attributes.class "w-6 h-6 text-white" ]
                        [ Icon.view { alt = "categories", icon = Icon.List }
                        ]
                    ]
                , Html.div [ Attributes.class "flex justify-center text-white rounded-full mt-16 mb-12" ]
                    [ Html.span [ Attributes.class "-ml-6 text-5xl" ] [ Html.text "$" ]
                    , Html.span
                        [ Attributes.class "-mt-4"
                        , Attributes.style "font-size" "7rem"
                        ]
                        [ Html.text "0" ]
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
                    [ Attributes.class "flex mt-6" ]
                    [ Html.div [ Attributes.class "w-1/2" ]
                        [ Html.button
                            [ Attributes.class "p-4 mr-px rounded-l-lg w-full"
                            , Attributes.style "background-color" "rgba(255,255,255,.1)"
                            ]
                            [ Html.span [ Attributes.class "text-white text-sm" ] [ Html.text "Credit" ]
                            ]
                        ]
                    , Html.div [ Attributes.class "w-1/2" ]
                        [ Html.button
                            [ Attributes.class "p-4 ml-px rounded-r-lg w-full"
                            , Attributes.style "background-color" "rgba(255,255,255,.1)"
                            ]
                            [ Html.span [ Attributes.class "text-white text-sm" ] [ Html.text "Debit" ]
                            ]
                        ]
                    ]
                ]
            ]
    }


keyPadButton : String -> Html msg
keyPadButton label =
    Html.div [ Attributes.class "w-1/3" ]
        [ Html.button [ Attributes.class "p-4 w-full" ]
            [ Html.span [ Attributes.class "text-white" ] [ Html.text label ]
            ]
        ]



-- UPDATE


type Msg
    = GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
