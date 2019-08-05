module Web.Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Navigation
import Html exposing (Attribute)
import Html.Attributes as Attributes
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | WalletDetail String


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map WalletDetail (Parser.s "detail" </> Parser.string)
        ]


href : Route -> Attribute msg
href targetRoute =
    Attributes.href (toString targetRoute)


toString : Route -> String
toString page =
    case page of
        Home ->
            Builder.absolute [] []

        WalletDetail id ->
            Builder.absolute [ "detail", id ] []


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


replaceUrl : Navigation.Key -> Route -> Cmd msg
replaceUrl key route =
    Navigation.replaceUrl key (toString route)
