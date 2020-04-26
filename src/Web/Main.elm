module Web.Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html
import Json.Decode exposing (Value)
import Url exposing (Url)
import Wallets.Session as Session exposing (Session)
import Web.Page as Page
import Web.Page.Blank as Blank
import Web.Page.Home as Home
import Web.Page.NotFound as NotFound
import Web.Page.Wallet as Wallet
import Web.Route as Route exposing (Route)


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | Wallet Wallet.Model


init : Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromViewer navKey))



-- VIEW


view : Model -> Document Msg
view model =
    let
        viewPage toMsg config =
            let
                { title, body } =
                    Page.view config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        NotFound _ ->
            viewPage (\_ -> Ignored) NotFound.view

        Redirect _ ->
            viewPage (\_ -> Ignored) Blank.view

        Home subModel ->
            viewPage HomeMsg (Home.view subModel)

        Wallet subModel ->
            viewPage WalletMsg (Wallet.view subModel)



-- UPDATE


type Msg
    = Ignored
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | HomeMsg Home.Msg
    | WalletMsg Wallet.Msg


toSession : Model -> Session
toSession page =
    case page of
        NotFound session ->
            session

        Redirect session ->
            session

        Home subModel ->
            Home.toSession subModel

        Wallet subModel ->
            Wallet.toSession subModel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Navigation.load href
                    )

        ( Ignored, _ ) ->
            ( model
            , Cmd.none
            )

        ( HomeMsg subMsg, Home subModel ) ->
            Home.update subMsg subModel
                |> updateWith Home HomeMsg model

        ( WalletMsg subMsg, Wallet subModel ) ->
            Wallet.update subMsg subModel
                |> updateWith Wallet WalletMsg model

        ( _, _ ) ->
            ( model
            , Cmd.none
            )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session
                |> updateWith Home HomeMsg model

        Just (Route.Wallet walletId) ->
            Wallet.init session walletId
                |> updateWith Wallet WalletMsg model



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Redirect session ->
            Sub.none

        NotFound session ->
            Sub.none

        Home subModel ->
            Home.subscriptions subModel
                |> Sub.map HomeMsg

        Wallet subModel ->
            Wallet.subscriptions subModel
                |> Sub.map WalletMsg


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }
