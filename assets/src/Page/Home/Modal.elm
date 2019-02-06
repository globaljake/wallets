module Page.Home.Modal exposing (Modal(..), Model, Msg, init, view)

import Html exposing (Html)
import Page.AddWallet as AddWallet
import Session exposing (Session)


type Model
    = AddWallet AddWallet.Model


type Modal
    = AddWalletModal


type Msg
    = AddWalletMsg AddWallet.Msg


init : Session -> Modal -> ( Model, Cmd Msg )
init session modal =
    case modal of
        AddWalletModal ->
            AddWallet.init session
                |> Tuple.mapFirst AddWallet
                |> Tuple.mapSecond (Cmd.map AddWalletMsg)


view : Model -> Html Msg
view model =
    case model of
        AddWallet subModel ->
            AddWallet.view subModel
                |> Html.map AddWalletMsg
