module Web.Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Navigation
import Html exposing (Attribute)
import Html.Attributes as Attributes
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), Parser)
import Wallets.WalletId as WalletId exposing (WalletId)


type Route
    = Home
    | Wallet WalletId


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Wallet (Parser.s "detail" </> WalletId.parser)
        ]


href : Route -> Attribute msg
href targetRoute =
    Attributes.href (toString targetRoute)


toString : Route -> String
toString page =
    case page of
        Home ->
            Builder.absolute [] []

        Wallet walletId ->
            Builder.absolute [ "detail", WalletId.toString walletId ] []


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


replaceUrl : Navigation.Key -> Route -> Cmd msg
replaceUrl key route =
    Navigation.replaceUrl key (toString route)
