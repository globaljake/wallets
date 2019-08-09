module Web.Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Browser.Navigation as Navigation
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Task
import Wallets.Session as Session exposing (Session)
import Wallets.Transaction as Transaction exposing (Transaction)
import Wallets.Ui.AddWallet as AddWallet
import Wallets.Ui.Button as Button
import Wallets.Ui.Icon as Icon
import Wallets.Ui.Spend as Spend
import Wallets.Wallet as Wallet exposing (Wallet)
import Web.Route as Route



-- TYPES


type alias Model =
    { session : Session
    , feed : List String
    , wallets : Dict String Wallet
    , modal : Maybe Modal
    }


toSession : Model -> Session
toSession model =
    model.session


type ModalMsg
    = AddWalletMsg AddWallet.Msg
    | SpendMsg Spend.Msg


type Msg
    = NoOp
    | SetModal InitModal
    | CloseModal
    | ModalMsg ModalMsg
    | WalletShowResponse (Result String Wallet)
    | WalletIndexResponse (Result String { feed : List String, wallets : Dict String Wallet })
    | WalletDeleteResponse (Result String String)
    | TransactionShowResponse (Result String Transaction)
    | Reload


type InitModal
    = InitAddWallet
    | InitSpend Wallet


type Modal
    = AddWallet AddWallet.Model
    | Spend Spend.Model



-- STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , feed = []
      , wallets = Dict.empty
      , modal = Nothing
      }
    , Cmd.batch
        [ Wallet.index
            |> Task.attempt WalletIndexResponse
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetModal init_ ->
            ( { model | modal = Just (modalInit init_) }
            , Cmd.none
            )

        CloseModal ->
            ( { model | modal = Nothing }
            , Cmd.none
            )

        ModalMsg subMsg ->
            modalUpdate subMsg model

        WalletShowResponse (Ok wallet) ->
            ( { model | wallets = Dict.insert (Wallet.id wallet) wallet model.wallets }
            , Wallet.index
                |> Task.attempt WalletIndexResponse
            )

        WalletShowResponse (Err _) ->
            ( model
            , Cmd.none
            )

        WalletIndexResponse (Ok { feed, wallets }) ->
            ( { model | feed = feed, wallets = wallets }
            , Cmd.none
            )

        WalletIndexResponse (Err _) ->
            ( model
            , Cmd.none
            )

        WalletDeleteResponse (Ok id) ->
            ( { model | wallets = Dict.remove id model.wallets }
            , Cmd.none
            )

        WalletDeleteResponse (Err _) ->
            ( model
            , Cmd.none
            )

        TransactionShowResponse (Ok transaction) ->
            ( model
            , Wallet.show (Transaction.walletId transaction)
                |> Task.attempt WalletShowResponse
            )

        TransactionShowResponse (Err _) ->
            ( model
            , Cmd.none
            )

        Reload ->
            ( model, Navigation.reloadAndSkipCache )


modalInit : InitModal -> Modal
modalInit init_ =
    case init_ of
        InitAddWallet ->
            AddWallet AddWallet.init

        InitSpend wallet ->
            Spend (Spend.init wallet)


modalUpdate : ModalMsg -> Model -> ( Model, Cmd Msg )
modalUpdate msg model =
    case ( msg, model.modal ) of
        ( AddWalletMsg subMsg, Just (AddWallet subModel) ) ->
            case AddWallet.update subMsg subModel of
                ( newSubModel, AddWallet.NoOp ) ->
                    ( { model | modal = Just (AddWallet newSubModel) }
                    , Cmd.none
                    )

                ( _, AddWallet.RequestSubmit createPayload ) ->
                    ( { model | modal = Nothing }
                    , Wallet.create createPayload
                        |> Task.attempt WalletShowResponse
                    )

        ( SpendMsg subMsg, Just (Spend subModel) ) ->
            case Spend.update subMsg subModel of
                ( newSubModel, Spend.NoOp ) ->
                    ( { model | modal = Just (Spend newSubModel) }
                    , Cmd.none
                    )

                ( _, Spend.RequestSubmit createTransactionPayload ) ->
                    ( { model | modal = Nothing }
                    , Transaction.create createTransactionPayload
                        |> Task.attempt TransactionShowResponse
                    )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Wallets"
    , content =
        Html.div [ Attributes.class "relative h-full" ]
            [ viewContent model
            , case model.modal of
                Just modal ->
                    viewModal modal

                Nothing ->
                    Html.text ""
            ]
    }


viewContent : Model -> Html Msg
viewContent model =
    Html.div [ Attributes.class "h-full relative overflow-auto" ]
        [ Html.header [ Attributes.class "flex relative z-10" ]
            [ Html.div
                [ Attributes.class "flex flex-1 mb-2 justify-center items-center"
                , Attributes.style "height" "105px"
                ]
                [ Html.span [ Attributes.class "h-6 w-6" ] [ Icon.check ]
                ]
            , Html.div
                [ Attributes.class "flex flex-col fixed top-0 left-0 px-4 pt-4 bg-white w-full"
                ]
                [ Html.div
                    [ Attributes.class "flex items-center justify-between" ]
                    [ Html.span [ Attributes.class "text-4xl font-semibold leading-none" ]
                        [ Html.text "Wallets"
                        ]
                    , Html.button
                        [ Attributes.class "rounded-full h-10 w-10 bg-red-300"
                        , Events.onClick Reload
                        ]
                        []
                    ]
                , Html.div [ Attributes.class "my-4 leading-none text-gray-500" ]
                    [ Html.span [] [ Html.text "AUGUST 2019" ]
                    ]
                ]
            ]
        , Html.main_ [ Attributes.class "flex flex-col px-4" ]
            [ Html.div [ Attributes.class "flex flex-col" ]
                (List.map item (model.feed |> List.filterMap (\x -> Dict.get x model.wallets)))
            , Html.button
                [ Attributes.class "text-xl font-semibold text-gray-500 text-center my-6"
                , Events.onClick (SetModal InitAddWallet)
                ]
                [ Html.text "+ New Wallet"
                ]
            ]
        ]


item : Wallet -> Html Msg
item wallet =
    let
        formatToDollars : Int -> String
        formatToDollars int =
            let
                sign =
                    if int < 0 then
                        "-$"

                    else
                        "$"
            in
            if int == 0 then
                "$0"

            else if abs int < 10 then
                String.concat [ sign, ".0", String.fromInt (abs int) ]

            else
                String.concat
                    [ sign
                    , String.dropRight 2 (String.fromInt (abs int))
                    , if String.right 2 (String.fromInt (abs int)) == "00" then
                        ""

                      else
                        "." ++ String.right 2 (String.fromInt (abs int))
                    ]
    in
    Html.div
        [ Attributes.class "p-5 my-2 bg-white rounded-lg shadow"
        ]
        [ Html.div [ Attributes.class "flex flex-col overflow-hidden" ]
            [ Html.a [ Route.href (Route.WalletDetail (Wallet.id wallet)) ]
                [ Html.div [ Attributes.class "flex justify-between" ]
                    [ Html.div [ Attributes.class "flex font-semibold text-xl items-center" ]
                        [ Html.span [ Attributes.class "pr-2" ] [ Html.text (Wallet.emoji wallet) ]
                        , Html.span [] [ Html.text (Wallet.title wallet) ]
                        ]
                    , Html.span [ Attributes.class "font-semibold text-xl" ]
                        [ Html.text <| formatToDollars (Wallet.available wallet)
                        ]
                    ]
                , Html.div [ Attributes.class "relative h-2 w-full mt-3 mb-2" ]
                    [ Html.div [ Attributes.class "h-full w-full bg-gray-300 rounded-full" ] []
                    , Html.div
                        [ Attributes.classList
                            [ ( "absolute inset-0 h-full rounded-full", True )
                            , ( "bg-green-400", Wallet.available wallet >= 0 )
                            , ( "bg-red-600", Wallet.available wallet < 0 )
                            ]
                        , Attributes.style "width"
                            (String.concat
                                [ String.fromFloat (Wallet.percentAvailable wallet)
                                , "%"
                                ]
                            )
                        ]
                        []
                    ]
                ]
            , Html.div [ Attributes.class "flex justify-between items center" ]
                [ Html.div [ Attributes.class "text-left" ]
                    [ if Wallet.available wallet == 0 then
                        Html.span [ Attributes.class "text-sm font-semibold text-gray-600" ]
                            [ Html.text "Awesome! You Stayed on Budget."
                            ]
                        --   else if Wallet.available wallet < 0 then
                        --     Html.span [ Attributes.class "text-sm font-semibold text-grey-600" ]
                        --         [ Html.text "Great job!"
                        --         ]

                      else if Wallet.budget wallet == Wallet.available wallet then
                        Html.span [ Attributes.class "text-sm font-semibold text-green-400" ]
                            [ Html.text "Ready to Spend!"
                            ]

                      else
                        Html.span
                            [ Attributes.classList
                                [ ( "text-sm", True )
                                , ( "text-gray-600", Wallet.available wallet > 0 )
                                , ( "text-red-600", Wallet.available wallet < 0 )
                                ]
                            ]
                            [ Html.span [ Attributes.class "font-semibold" ]
                                [ Html.text <| formatToDollars (Wallet.spent wallet)
                                ]
                            , Html.span [ Attributes.class "px-1" ] [ Html.text "of" ]
                            , Html.span [ Attributes.class "font-semibold pr-1" ]
                                [ Html.text <| formatToDollars (Wallet.budget wallet)
                                ]
                            , Html.span [] [ Html.text "spent" ]
                            ]
                    ]
                , Html.div [ Attributes.class "" ]
                    [ Html.button
                        [ Events.onClick <| SetModal (InitSpend wallet)
                        , Attributes.classList
                            [ ( "font-semibold text-sm", True )
                            , ( "text-gray-600", Wallet.available wallet == 0 )
                            , ( "text-green-400", Wallet.available wallet > 0 )
                            , ( "text-red-600", Wallet.available wallet < 0 )
                            ]
                        ]
                        [ Html.text "SPEND"
                        ]
                    ]
                ]
            ]
        ]


viewModal : Modal -> Html Msg
viewModal modal =
    let
        mHelp text content =
            Html.div [ Attributes.class "h-full flex flex-col" ]
                [ Html.div [ Attributes.class "flex pt-4 pb-6 border-b items-center" ]
                    [ Html.button [ Events.onClick CloseModal ]
                        [ Html.span
                            [ Attributes.class "p-2 w-8 h-8 flex justify-center items-center font-semibold"
                            ]
                            [ Html.text "X" ]
                        ]
                    , Html.div [ Attributes.class "flex flex-1 justify-center" ]
                        [ Html.span [ Attributes.class "text-xl font-semibold" ] [ Html.text text ]
                        ]
                    , Html.div [ Attributes.class "p-2 w-8 h-8" ] []
                    ]
                , Html.div [ Attributes.class "flex flex-1 flex-col p-4" ] [ content ]
                ]
    in
    Html.div [ Attributes.class "absolute inset-0 bg-white h-screen z-50" ]
        [ case modal of
            AddWallet subModel ->
                AddWallet.view subModel
                    |> Html.map (ModalMsg << AddWalletMsg)
                    |> mHelp "Add Wallet"

            Spend subModel ->
                Spend.view subModel
                    |> Html.map (ModalMsg << SpendMsg)
                    |> mHelp "Spend"
        ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
