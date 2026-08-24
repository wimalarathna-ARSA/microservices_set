(ns microservice-12.core
  (:require [ring.adapter.jetty :refer [run-jetty]]))

(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/plain"}
   :body "Hello from Microservice 12 (Clojure Ring)"})

(defn -main []
  (run-jetty handler {:port 3012}))