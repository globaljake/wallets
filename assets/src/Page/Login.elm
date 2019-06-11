module Page.Login exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The login page.
-}

import Api exposing (Cred)
import Browser.Navigation as Nav
import Constants
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import Route exposing (Route)
import Session exposing (Session)
import Viewer exposing (Viewer)



-- MODEL


type alias Model =
    { session : Session
    , email : String
    , password : String
    }


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , email = ""
      , password = ""
      }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content =
        Html.div [ Attributes.class "flex flex-col h-full justify-end" ]
            [ Html.div
                [ Attributes.class "flex flex-1 relative items-end"
                , Attributes.style "background" "linear-gradient(#f3f3f3 0%,#e3e3e3 100%)"
                ]
                [ Html.div [ Attributes.class "flex flex-col items-center text-center px-6 mb-24" ]
                    [ Html.span [ Attributes.class "font-serif text-5xl mb-6" ]
                        [ Html.text "Wallets"
                        ]
                    , Html.span [ Attributes.class "font-light text-lg mx-10 leading-normal" ]
                        [ Html.text "Make It Easy To Stay On Top Of Your Budget!"
                        ]
                    ]
                , Html.div
                    [ Attributes.class "absolute pin-b w-full h-32 -m-px"
                    , Attributes.style "background" ("url('" ++ Constants.toAsset "images/test-2.svg" ++ "')")
                    , Attributes.style "background-repeat" "no-repeat"
                    , Attributes.style "background-size" "contain"
                    , Attributes.style "background-position" "bottom"
                    ]
                    []
                ]
            , Html.div [ Attributes.class "flex flex-col p-6" ]
                [ Html.div [ Attributes.class "py-4" ]
                    [ input
                        { value = model.email
                        , placeholder = "Email"
                        , onInput = EmailEntered
                        , isRequired = True
                        , type_ = "text"
                        }
                    ]
                , Html.div [ Attributes.class "py-4" ]
                    [ input
                        { value = model.password
                        , placeholder = "Password"
                        , onInput = PasswordEntered
                        , isRequired = True
                        , type_ = "password"
                        }
                    ]
                , Html.button [ Attributes.class "flex justify-center py-6 my-6" ]
                    [ Html.span [ Attributes.class "font-medium text-xl text-grey-dark" ]
                        [ Html.text "Sign In / Sign Up"
                        ]
                    ]
                ]
            ]
    }



-- UPDATE


type Msg
    = GotSession Session
    | EmailEntered String
    | PasswordEntered String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }
            , Cmd.none
            )

        EmailEntered email ->
            ( { model | email = email }
            , Cmd.none
            )

        PasswordEntered password ->
            ( { model | password = password }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session



-- INTERNAL


type alias InputConfig msg =
    { value : String
    , placeholder : String
    , isRequired : Bool
    , onInput : String -> msg
    , type_ : String
    }


input : InputConfig msg -> Html msg
input config =
    Html.input
        [ Attributes.classList
            [ ( "text-center text-xl text-grey-dark bg-transparent  border-b-2 w-full p-6 outline-none", True )
            , ( "border-grey-light focus:border-grey", String.isEmpty config.value )
            , ( "border-grey-dark focus:border-grey-dark", not <| String.isEmpty config.value )
            ]
        , Attributes.value config.value
        , Events.onInput config.onInput
        , Attributes.placeholder config.placeholder
        , Attributes.attribute "aria-required" <|
            if config.isRequired then
                "true"

            else
                "false"
        , Attributes.type_ config.type_
        ]
        []
