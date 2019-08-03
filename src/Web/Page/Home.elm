module Web.Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Wallets.Session as Session exposing (Session)
import Wallets.Ui.Button as Button
import Wallets.Wallet as Wallet exposing (Wallet)



-- TYPES


type alias Model =
    { session : Session
    , wallets : List Wallet
    , modal : Maybe Modal
    }


toSession : Model -> Session
toSession model =
    model.session


type Msg
    = NoOp
    | SetModal Modal
    | CloseModal
    | WalletIndexResponse (Result String (List Wallet))
    | WalletCreate
    | WalletDelete String


type Modal
    = AddWallet
    | Spend Wallet



-- STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session

      --   , wallets = Wallet.mockList
      , wallets = []
      , modal = Nothing
      }
    , Wallet.index
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetModal modal ->
            ( { model | modal = Just modal }
            , Cmd.none
            )

        CloseModal ->
            ( { model | modal = Nothing }
            , Cmd.none
            )

        WalletIndexResponse (Ok wallets) ->
            ( { model | wallets = wallets }
            , Cmd.none
            )

        WalletIndexResponse (Err _) ->
            ( model
            , Cmd.none
            )

        WalletCreate ->
            ( { model | modal = Nothing }
            , Wallet.create { title = "Shopping", emoji = "🛍", budget = 100, available = 50 }
            )

        WalletDelete id ->
            ( { model | modal = Nothing }
            , Wallet.delete id
            )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Wallets"
    , content =
        Html.div [ Attributes.class "relative h-full" ]
            [ viewContent model
            , case model.modal of
                Nothing ->
                    Html.text ""

                Just modal ->
                    viewModal modal
            ]
    }


viewContent : Model -> Html Msg
viewContent model =
    Html.div [ Attributes.class "h-full overflow-auto p-4" ]
        [ Html.div [ Attributes.class "flex flex-col" ]
            [ Html.div
                [ Attributes.class "flex items-center justify-between" ]
                [ Html.span [ Attributes.class "text-4xl font-semibold leading-none" ]
                    [ Html.text "Wallets"
                    ]
                , Html.div [ Attributes.class "rounded-full h-10 w-10 bg-red-300" ] []
                ]
            , Html.div [ Attributes.class "my-4 leading-none text-gray-500" ]
                [ Html.span [] [ Html.text "AUGUST 2019" ]
                ]
            ]
        , Html.div [ Attributes.class "flex flex-col" ]
            [ Html.div [ Attributes.class "flex flex-col" ]
                (List.map item model.wallets)
            , Html.button
                [ Attributes.class "text-xl font-semibold text-gray-500 text-center my-6"
                , Events.onClick (SetModal AddWallet)
                ]
                [ Html.text "+ New Wallet"
                ]
            ]
        ]


item : Wallet -> Html Msg
item wallet =
    Html.button
        [ Attributes.class "p-5 my-2 bg-white rounded-lg shadow"
        , Events.onClick <| SetModal (Spend wallet)
        ]
        [ Html.div [ Attributes.class "flex flex-col pointer-events-none" ]
            [ Html.div [ Attributes.class "flex justify-between" ]
                [ Html.div [ Attributes.class "flex font-semibold text-xl items-center" ]
                    [ Html.span [ Attributes.class "pr-2" ] [ Html.text (Wallet.emoji wallet) ]
                    , Html.span [] [ Html.text (Wallet.title wallet) ]
                    ]
                , Html.span [ Attributes.class "font-semibold text-xl" ]
                    [ Html.text <| String.concat [ "$", String.fromFloat (Wallet.available wallet) ]
                    ]
                ]
            , Html.div [ Attributes.class "relative h-2 w-full mt-3 mb-2" ]
                [ Html.div [ Attributes.class "relative h-full w-full bg-gray-300 rounded-full" ] []
                , Html.div
                    [ Attributes.class "absolute inset-0 h-full bg-green-400 rounded-full"
                    , Attributes.style "width"
                        (String.concat
                            [ String.fromFloat (Wallet.percentAvailable wallet)
                            , "%"
                            ]
                        )
                    ]
                    []
                ]
            , Html.div [ Attributes.class "text-left" ]
                [ if Wallet.budget wallet == Wallet.available wallet then
                    Html.span [ Attributes.class "text-sm font-semibold text-green-400" ]
                        [ Html.text "Ready to Spend!"
                        ]
                    --   else if wallet.available <= 0 then
                    --     Html.span [ Attributes.class "text-sm font-semibold text-green-400" ]
                    --         [ Html.text "Great job!"
                    --         ]

                  else
                    Html.span [ Attributes.class "text-sm text-gray-600" ]
                        [ Html.span [ Attributes.class "font-semibold" ]
                            [ Html.text <|
                                String.concat
                                    [ "$"
                                    , String.fromFloat (Wallet.spent wallet)
                                    ]
                            ]
                        , Html.span [ Attributes.class "px-1" ] [ Html.text "of" ]
                        , Html.span [ Attributes.class "font-semibold pr-1" ]
                            [ Html.text <|
                                String.concat [ "$", String.fromFloat (Wallet.budget wallet) ]
                            ]
                        , Html.span [] [ Html.text "spent" ]
                        ]
                ]
            ]
        ]


viewModal : Modal -> Html Msg
viewModal modal =
    let
        mHelp text content =
            Html.div []
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
                , Html.div [ Attributes.class "p-4" ] [ content ]
                ]
    in
    Html.div [ Attributes.class "absolute inset-0 bg-white h-screen" ]
        [ case modal of
            AddWallet ->
                mHelp "Add Wallet" viewAddWallet

            Spend wallet ->
                mHelp "Spend" (viewSpend wallet)
        ]


viewAddWallet : Html Msg
viewAddWallet =
    Html.div []
        [ Html.text "add wallet!!!!!!!!"
        , Html.button [ Events.onClick WalletCreate ]
            [ Html.text "Create Shopping"
            ]
        ]


viewSpend : Wallet -> Html Msg
viewSpend wallet =
    Html.div []
        [ Html.text (Wallet.title wallet)
        , Html.button [ Events.onClick (WalletDelete (Wallet.id wallet)) ]
            [ Html.text "Delete"
            ]
        ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Wallet.indexResponse WalletIndexResponse
