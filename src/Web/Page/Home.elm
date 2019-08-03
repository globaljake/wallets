module Web.Page.Home exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Wallets.Session as Session exposing (Session)
import Wallets.Ui.Button as Button



-- TYPES


type alias Model =
    { session : Session
    }


toSession : Model -> Session
toSession model =
    model.session


type Msg
    = NoOp



-- STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Wallets"
    , content =
        Html.div []
            [ Html.div [ Attributes.class "flex items-center justify-between" ]
                [ Html.span [ Attributes.class "text-4xl font-semibold leading-none" ] [ Html.text "Wallets" ]
                , Html.div [ Attributes.class "rounded-full h-10 w-10 bg-red-300" ] []
                ]
            , Html.div [ Attributes.class "my-4 leading-none text-gray-500" ]
                [ Html.span [] [ Html.text "JULY 2019" ]
                ]
            , Html.div [ Attributes.class "flex flex-col" ]
                (List.map item itemsMock)
            ]
    }


itemsMock : List ItemConfig
itemsMock =
    [ { title = "Shopping", emoji = "🛍", budget = 100, left = 50 }
    , { title = "Entertainment", emoji = "🎬", budget = 50, left = 50 }
    , { title = "Groceries", emoji = "\u{1F951}", budget = 100, left = 75 }
    , { title = "Eating Out", emoji = "🍕", budget = 80, left = 0 }
    ]


type alias ItemConfig =
    { title : String, emoji : String, budget : Float, left : Float }


item : ItemConfig -> Html msg
item config =
    Html.button [ Attributes.class "p-5 my-2 bg-white rounded-lg shadow" ]
        [ Html.div [ Attributes.class "flex flex-col" ]
            [ Html.div [ Attributes.class "flex justify-between" ]
                [ Html.div [ Attributes.class "flex font-semibold text-xl items-center" ]
                    [ Html.span [ Attributes.class "pr-2" ] [ Html.text config.emoji ]
                    , Html.span [] [ Html.text config.title ]
                    ]
                , Html.span [ Attributes.class "font-semibold text-xl" ]
                    [ Html.text <| String.concat [ "$", String.fromFloat config.left ]
                    ]
                ]
            , Html.div [ Attributes.class "relative h-2 w-full mt-3 mb-2" ]
                [ Html.div [ Attributes.class "relative h-full w-full bg-gray-300 rounded-full" ] []
                , Html.div
                    [ Attributes.class "absolute inset-0 h-full bg-green-400 rounded-full"
                    , Attributes.style "width"
                        (String.concat
                            [ String.fromFloat (config.left / config.budget * 100)
                            , "%"
                            ]
                        )
                    ]
                    []
                ]
            , Html.div [ Attributes.class "text-left" ]
                [ if config.budget == config.left then
                    Html.span [ Attributes.class "text-sm font-semibold text-green-400" ]
                        [ Html.text "Ready to Spend!"
                        ]

                  else if config.left <= 0 then
                    Html.span [ Attributes.class "text-sm text-gray-600" ]
                        [ Html.span [ Attributes.class "font-semibold" ] [ Html.text "$50" ]
                        , Html.span [ Attributes.class "px-1" ] [ Html.text "of" ]
                        , Html.span [ Attributes.class "font-semibold pr-1" ] [ Html.text "$100" ]
                        , Html.span [] [ Html.text "spent" ]
                        ]

                  else
                    Html.span [ Attributes.class "text-sm text-gray-600" ]
                        [ Html.span [ Attributes.class "font-semibold" ] [ Html.text "$50" ]
                        , Html.span [ Attributes.class "px-1" ] [ Html.text "of" ]
                        , Html.span [ Attributes.class "font-semibold pr-1" ] [ Html.text "$100" ]
                        , Html.span [] [ Html.text "spent" ]
                        ]
                ]
            ]
        ]
