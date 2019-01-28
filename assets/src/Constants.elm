module Constants exposing (toAsset)


toAsset : String -> String
toAsset =
    String.append "%ASSET_PATH%"
