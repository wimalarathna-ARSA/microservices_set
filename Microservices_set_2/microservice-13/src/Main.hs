{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Network.Wai
import Network.Wai.Handler.Warp
import Servant

type API = Get '[PlainText] String

server :: Server API
server = return "Hello from Microservice 13 (Haskell Servant)"

app :: Application
app = serve (Proxy :: Proxy API) server

main :: IO ()
main = run 3013 app