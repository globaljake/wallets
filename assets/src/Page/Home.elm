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
import Page
import Page.Home.Modal as Modal
import Route
import Session exposing (Session)
import Task exposing (Task)
import Time
import Ui.Icon as Icon
import Ui.Modal as Modal
import Ui.Transition as Transition
import Url.Builder
import Username exposing (Username)



-- MODEL


type alias Model =
    { session : Session
    , modalState : Maybe Modal.Model
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, modalState = Nothing }
    , Transition.start
    )



-- VIEW


feedMock : List ( String, Int )
feedMock =
    [ ( "Shopping", 2 )
    , ( "Groceries", -2 )
    , ( "Groceries", 2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", 2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    , ( "Groceries", -2 )
    ]


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content =
        Html.div [ Attributes.class "overflow-hidden h-full relative" ]
            [ content model
            , case model.modalState of
                Nothing ->
                    Html.text ""

                Just ms ->
                    Modal.display
                        { body =
                            Modal.view ms
                                |> Html.map ModalMsg
                        , onClose = SetModal Nothing
                        }
            ]
    }


content : Model -> Html Msg
content model =
    Html.div
        [ Attributes.class "flex flex-col h-full overflow-auto scrolling-touch relative"
        ]
        [ Html.div [ Attributes.class "py-5 border-b" ]
            [ Html.div [ Attributes.class "flex pt-6 sticky pin-t bg-grey-light" ]
                [ Html.div [ Attributes.class "flex w-full items-center py-5 px-6" ]
                    [ Html.a [ Route.href Route.Profile ]
                        [ Html.span
                            [ Attributes.class "flex w-8 h-8 border-2 border-grey-dark rounded-full"
                            , Attributes.style "background-image" "url(https://github.com/globaljake.png)"
                            , Attributes.style "background-size" "contain"
                            ]
                            []
                        ]
                    , logo
                    , Html.button []
                        [ Html.span
                            [ Attributes.class "flex h-8 w-8 text-grey-dark"
                            ]
                            [ Icon.view { alt = "Settings", icon = Icon.Cog } ]
                        ]
                    ]
                ]
            , Html.div [ Attributes.class "flex flex-col px-6" ]
                [ Html.span [ Attributes.class "text-5xl text-center font-medium leading-none py-5" ]
                    [ Html.text "$0.00"
                    ]
                , Html.span [ Attributes.class "text-lg pb-10 text-center" ]
                    [ Html.text "Monthly Balance"
                    ]
                ]
            , Html.div []
                [ Html.div [] (List.map feedItem feedMock)
                , Html.button
                    [ Events.onClick <| SetModal (Just Modal.AddWalletModal)
                    , Attributes.class "flex justify-between items-center p-6 text-grey w-full"
                    ]
                    [ Html.span [ Attributes.class "leading-none font-light italic text-2xl" ]
                        [ Html.text "Add Wallet"
                        ]
                    , Html.span [ Attributes.class "h-8 w-8 text-grey" ]
                        [ Icon.view { alt = "Add Wallet", icon = Icon.AddCircle }
                        ]
                    ]
                ]
            ]
        ]


logo : Html msg
logo =
    Html.div [ Attributes.class "flex flex-1 justify-center items-center border-grey-dark" ]
        [ Html.span
            [ Attributes.class "leading-none"
            , Attributes.style "font-size" "2.5rem"
            , Attributes.style "font-family" "Pacifico"
            ]
            [ Html.text "Wallets"
            ]
        ]


feedItem : ( String, Int ) -> Html msg
feedItem ( text, amount ) =
    Html.button [ Attributes.class "bg-off-white px-6 w-full text-grey-dark" ]
        [ Html.span [ Attributes.class "flex items-center border-b" ]
            [ Html.span [ Attributes.class "h-6 w-6 text-grey-dark" ]
                [ Icon.view { alt = "Wallet", icon = Icon.Wallet }
                ]
            , Html.span [ Attributes.class "flex flex-1 py-10 px-4 text-xl" ] [ Html.text text ]
            , Html.span
                [ Attributes.classList
                    [ ( "text-xl", True )
                    , ( "text-red", amount == 0 )
                    , ( "text-green", amount > 0 )
                    , ( "text-red", amount < 0 )
                    ]
                ]
                [ Html.text <|
                    String.concat
                        [ if amount < 0 then
                            "-"

                          else
                            ""
                        , "$2.00"
                        ]
                ]
            ]
        ]


addWalletView : Model -> Html Msg
addWalletView model =
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
                    [ Attributes.class "text-white rounded-full px-4 py-2"
                    , Attributes.style "background-color" "rgba(255,255,255,.1)"
                    ]
                    [ Html.text "$200.00" ]
                , Html.button [ Attributes.class "w-8 h-8 text-white" ]
                    [ Icon.view { alt = "categories", icon = Icon.List }
                    ]
                ]
            , Html.div [ Attributes.class "flex flex-1 justify-center items-center my-8" ]
                [ Html.div [ Attributes.class "flex justify-center text-white" ]
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
                        [ Html.span [ Attributes.class "text-white font-medium text-xl" ]
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
            [ Html.span [ Attributes.class "text-white text-2xl" ] [ Html.text label ]
            ]
        ]



-- UPDATE


type Msg
    = GotSession Session
    | SettingsCogClicked
    | ModalMsg Modal.Msg
    | SetModal (Maybe Modal.Modal)
    | NoOp



-- type ModalMsg
--     = AddWalletMsg AddWallet.Msg
--     | AddToBalanceMsg AddToBalance.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        session =
            toSession model
    in
    case msg of
        GotSession newSession ->
            ( { model | session = newSession }
            , Cmd.none
            )

        SettingsCogClicked ->
            ( model
            , Cmd.none
            )

        ModalMsg subMsg ->
            ( model, Cmd.none )

        SetModal maybeModal ->
            case maybeModal of
                Nothing ->
                    ( { model | modalState = Nothing }, Cmd.none )

                Just modal ->
                    Modal.init session modal
                        |> Tuple.mapFirst (\ms -> { model | modalState = Just ms })
                        |> Tuple.mapSecond (Cmd.map ModalMsg)

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
