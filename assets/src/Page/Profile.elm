module Page.Profile exposing (Model, Msg, init, subscriptions, toSession, update, view)

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
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Transition.start
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content = content model
    }


content : Model -> Html Msg
content model =
    Html.div [] [ Html.text "HELLO" ]



-- UPDATE


type Msg
    = GotSession Session
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
