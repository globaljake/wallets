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
import Page.Register as Register
import Route exposing (Route)
import Session exposing (Session)
import Task
import Time
import Url exposing (Url)
import Username exposing (Username)
import Viewer exposing (Viewer)



-- NOTE: Based on discussions around how asset management features
-- like code splitting and lazy loading have been shaping up, it's possible
-- that most of this file may become unnecessary in a future release of Elm.
-- Avoid putting things in this module unless there is no alternative!
-- See https://discourse.elm-lang.org/t/elm-spa-in-0-19/1800/2 for more.


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
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
            viewPage Page.Home GotHomeMsg (Home.view home)

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
    | GotHomeMsg Home.Msg
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
                |> updateWith Home GotHomeMsg model

        Just Route.Login ->
            Login.init session
                |> updateWith Login GotLoginMsg model

        Just Route.Register ->
            Register.init session
                |> updateWith Register GotRegisterMsg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ChangedRoute route, _ ) ->
            changeRouteTo route model

        ( GotLoginMsg subMsg, Login login ) ->
            Login.update subMsg login
                |> updateWith Login GotLoginMsg model

        ( GotRegisterMsg subMsg, Register register ) ->
            Register.update subMsg register
                |> updateWith Register GotRegisterMsg model

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg model

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
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession model))

        Home home ->
            Sub.map GotHomeMsg (Home.subscriptions home)

        Login login ->
            Sub.map GotLoginMsg (Login.subscriptions login)

        Register register ->
            Sub.map GotRegisterMsg (Register.subscriptions register)



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



-- -- VIEW
-- view : Model -> Browser.Document Msg
-- view model =
--     { title = "URL Interceptor"
--     , body =
--         [ Ui.IconInjector.view
--         , div [ class "h-full bg-grey-lightest" ]
--             [ span [ class "flex items-center" ]
--                 [ text "The current URL is:"
--                 , span [ class "text-green w-4 h-4 mx-1" ]
--                     [ Ui.Icon.view { alt = "Check Mark", icon = Ui.Icon.Check }
--                     ]
--                 , b [] [ text (Url.toString model.url) ]
--                 ]
--             , ul []
--                 [ viewLink "/home"
--                 , viewLink "/profile"
--                 , viewLink "/reviews/the-century-of-the-self"
--                 , viewLink "/reviews/public-opinion"
--                 , viewLink "/reviews/shah-of-shahs"
--                 ]
--             ]
--         ]
--     }
