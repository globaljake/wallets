module Main exposing (main)

import Api exposing (Cred)
import Avatar exposing (Avatar)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Page exposing (Page)
import Page.Blank as Blank
import Page.Home as Home
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Profile as Profile
import Page.Register as Register
import Process
import Route exposing (Route)
import Session exposing (Session)
import Task
import Time
import Ui.Transition as Transition
import Url exposing (Url)
import Username exposing (Username)
import Viewer exposing (Viewer)


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | Profile Profile.Model
    | Login Login.Model
    | Register Register.Model



-- MODEL


init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromViewer navKey maybeViewer))



-- VIEW


view : Model -> Document Msg
view model =
    let
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view (Session.viewer (toSession model)) page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            viewPage Page.Other (\_ -> Ignored) Blank.view

        NotFound _ ->
            viewPage Page.Other (\_ -> Ignored) NotFound.view

        Home home ->
            viewPage Page.Home HomeMsg (Home.view home)

        Profile profile ->
            viewPage Page.Profile ProfileMsg (Profile.view profile)

        Login login ->
            viewPage Page.Other GotLoginMsg (Login.view login)

        Register register ->
            viewPage Page.Other GotRegisterMsg (Register.view register)



-- UPDATE


type Msg
    = Ignored
    | ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | TransitionSet (Maybe Url)
    | HomeMsg Home.Msg
    | ProfileMsg Profile.Msg
    | GotLoginMsg Login.Msg
    | GotRegisterMsg Register.Msg
    | GotSession Session


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Profile profile ->
            Home.toSession profile

        Login login ->
            Login.toSession login

        Register register ->
            Register.toSession register


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Home )

        Just Route.Logout ->
            ( model, Api.logout )

        Just Route.Home ->
            Home.init session
                |> updateWith Home HomeMsg model

        Just Route.Profile ->
            Profile.init session
                |> updateWith Profile ProfileMsg model

        Just Route.Login ->
            Login.init session
                |> updateWith Login GotLoginMsg model

        Just Route.Register ->
            Register.init session
                |> updateWith Register GotRegisterMsg model


transitionDirection : Maybe Route -> Model -> Transition.Direction
transitionDirection maybeRoute model =
    case ( model, maybeRoute ) of
        ( Home _, Just Route.Profile ) ->
            Transition.Right

        ( Profile _, Just Route.Home ) ->
            Transition.Left

        _ ->
            Transition.Left


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( TransitionSet (Just url), _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ChangedUrl url, _ ) ->
            ( model
            , Cmd.batch
                [ model
                    |> transitionDirection (Route.fromUrl url)
                    |> Transition.setup url
                ]
            )

        ( ChangedRoute route, _ ) ->
            changeRouteTo route model

        ( GotLoginMsg subMsg, Login login ) ->
            Login.update subMsg login
                |> updateWith Login GotLoginMsg model

        ( GotRegisterMsg subMsg, Register register ) ->
            Register.update subMsg register
                |> updateWith Register GotRegisterMsg model

        ( HomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home HomeMsg model

        ( ProfileMsg subMsg, Profile profile ) ->
            Profile.update subMsg profile
                |> updateWith Profile ProfileMsg model

        ( GotSession session, Redirect _ ) ->
            ( Redirect session
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Transition.subscription (TransitionSet << Url.fromString)
        , case model of
            NotFound _ ->
                Sub.none

            Redirect _ ->
                Session.changes GotSession (Session.navKey (toSession model))

            Home home ->
                Sub.map HomeMsg (Home.subscriptions home)

            Profile profile ->
                Sub.map ProfileMsg (Profile.subscriptions profile)

            Login login ->
                Sub.map GotLoginMsg (Login.subscriptions login)

            Register register ->
                Sub.map GotRegisterMsg (Register.subscriptions register)
        ]



-- MAIN


main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
