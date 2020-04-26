module Web.Page.Wallet exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Task
import Wallets.Session as Session exposing (Session)
import Wallets.Transaction as Transaction exposing (Transaction)
import Wallets.Ui.AddWallet as AddWallet
import Wallets.Ui.Button as Button
import Wallets.Ui.Spend as Spend
import Wallets.Wallet as Wallet exposing (Wallet)
import Wallets.WalletId as WalletId exposing (WalletId)
import Web.Route as Route



-- TYPES


type alias Model =
    { session : Session
    , walletId : WalletId
    , transactionFeed : List String
    , wallets : Dict String Wallet
    , transactions : Dict String Transaction
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
    | WalletShowResponse (Result Http.Error Wallet)
    | WalletDelete WalletId
    | WalletDeleteResponse (Result Http.Error WalletId)
    | TransactionIndexResponse (Result Http.Error { feed : List String, transactions : Dict String Transaction })
    | TransactionShowResponse (Result Http.Error Transaction)


type InitModal
    = InitAddWallet
    | InitSpend Wallet


type Modal
    = AddWallet AddWallet.Model
    | Spend Spend.Model



-- STATE


init : Session -> WalletId -> ( Model, Cmd Msg )
init session walletId =
    ( { session = session
      , walletId = walletId
      , transactionFeed = []
      , wallets = Dict.empty
      , transactions = Dict.empty
      , modal = Nothing
      }
    , Cmd.batch
        [ Transaction.indexByWalletId walletId
            |> Task.attempt TransactionIndexResponse
        , Wallet.show walletId
            |> Task.attempt WalletShowResponse
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
            ( { model | wallets = Dict.insert (WalletId.toString <| Wallet.id wallet) wallet model.wallets }
            , Cmd.none
            )

        WalletShowResponse (Err _) ->
            ( model
            , Cmd.none
            )

        WalletDelete id ->
            ( model
            , Task.attempt WalletDeleteResponse (Wallet.delete id)
            )

        WalletDeleteResponse (Ok id) ->
            ( model
            , Route.replaceUrl (Session.navKey model.session) Route.Home
            )

        WalletDeleteResponse (Err _) ->
            ( model
            , Cmd.none
            )

        TransactionShowResponse (Ok transaction) ->
            ( { model
                | transactions =
                    Dict.insert (Transaction.id transaction) transaction model.transactions
              }
            , Cmd.batch
                [ Transaction.indexByWalletId model.walletId
                    |> Task.attempt TransactionIndexResponse
                , Wallet.show model.walletId
                    |> Task.attempt WalletShowResponse
                ]
            )

        TransactionShowResponse (Err _) ->
            ( model
            , Cmd.none
            )

        TransactionIndexResponse (Ok { feed, transactions }) ->
            ( { model | transactionFeed = feed, transactions = transactions }
            , Cmd.none
            )

        TransactionIndexResponse (Err _) ->
            ( model
            , Cmd.none
            )


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

                ( _, Spend.RequestSubmit transactionCreatePayload ) ->
                    ( { model | modal = Nothing }
                    , Transaction.create transactionCreatePayload
                        |> Task.attempt TransactionShowResponse
                    )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Wallet"
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
    Html.div [ Attributes.class "h-full overflow-auto bg-white jake-remove-bg-white" ]
        [ Html.div [ Attributes.class "flex flex-col border-b  bg-white" ]
            [ Html.div [ Attributes.class "flex p-4 items-center" ]
                [ Html.a [ Route.href Route.Home ]
                    [ Html.span
                        [ Attributes.class "p-2 w-8 h-8 flex justify-center items-center font-semibold"
                        ]
                        [ Html.text "<" ]
                    ]
                , Html.div [ Attributes.class "flex flex-1 justify-center" ]
                    [ case Dict.get (WalletId.toString model.walletId) model.wallets of
                        Nothing ->
                            Html.span [ Attributes.class "text-xl font-semibold" ]
                                [ Html.text ""
                                ]

                        Just wallet ->
                            Html.div [ Attributes.class "flex flex-col text-center" ]
                                [ Html.span [ Attributes.class "text-4xl" ]
                                    [ Html.text (Wallet.emoji wallet)
                                    ]
                                , Html.span [ Attributes.class "text-2xl font-semibold" ]
                                    [ Html.text (Wallet.name wallet)
                                    ]
                                , Html.span
                                    [ Attributes.classList
                                        [ ( "text-4xl font-semibold", True )
                                        , ( "text-red-600", Wallet.available wallet < 0 )
                                        , ( "text-green-400", Wallet.available wallet > 0 )
                                        ]
                                    ]
                                    [ Html.text <| formatToDollars (Wallet.available wallet)
                                    ]
                                ]
                    ]
                , Html.div [ Attributes.class "p-2 w-8 h-8" ] []
                ]
            , case Dict.get (WalletId.toString model.walletId) model.wallets of
                Nothing ->
                    Html.span [ Attributes.class "text-xl font-semibold" ]
                        [ Html.text ""
                        ]

                Just wallet ->
                    Html.div [ Attributes.class "flex flex-col" ]
                        [ Html.div [ Attributes.class "flex px-10" ]
                            [ Html.div [ Attributes.class "relative h-2 w-full mt-3 mb-2" ]
                                [ Html.div
                                    [ Attributes.class "relative h-full w-full bg-gray-300 rounded-full"
                                    ]
                                    []
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
                        , Html.div [ Attributes.class "flex justify-between items center px-10" ]
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
                            ]
                        , Html.div [ Attributes.class "flex justify-between" ]
                            [ Html.button
                                [ Attributes.class "text-lg p-4 font-semibold text-red-600 text-center my-6"
                                , Events.onClick <| WalletDelete (Wallet.id wallet)
                                ]
                                [ Html.text "Delete"
                                ]
                            , Html.button
                                [ Attributes.class "text-lg p-4 font-semibold text-green-400 text-center my-6"
                                , Events.onClick <| SetModal (InitSpend wallet)
                                ]
                                [ Html.text "Spend"
                                ]
                            ]
                        ]
            ]
        , Html.div [ Attributes.class "flex flex-col bg-white" ]
            [ Html.div
                [ Attributes.class "flex text-gray-800 text-lg p-4 bg-gray-100 font-semibold"
                ]
                [ Html.text "AUGUST"
                ]
            , Html.div [ Attributes.class "flex flex-col p-4" ]
                (List.map item (model.transactionFeed |> List.filterMap (\x -> Dict.get x model.transactions)))
            ]
        ]


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


item : Transaction -> Html Msg
item transaction =
    let
        amt =
            Transaction.amount transaction * -1
    in
    Html.div
        [ Attributes.class "flex items-center p-5 my-2 border-b"
        ]
        [ Html.div [ Attributes.class "flex " ]
            [ Html.span
                [ Attributes.class "rounded-full h-8 w-8 bg-red-300"
                ]
                []
            ]
        , Html.div [ Attributes.class "flex flex-1" ]
            [ Html.span [ Attributes.class "px-4 text-lg font-semibold" ]
                [ Html.text (Transaction.description transaction)
                ]
            ]
        , Html.div [ Attributes.class "flex" ]
            [ Html.span
                [ Attributes.classList
                    [ ( "font-semibold text-lg", True )
                    , ( "text-red-600", amt < 0 )
                    , ( "text-green-400", amt > 0 )
                    ]
                ]
                [ Html.text (formatToDollars amt)
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
    Html.div [ Attributes.class "absolute inset-0 bg-white h-screen" ]
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
