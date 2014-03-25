express = require("express")
oauthserver = require("node-oauth2-server")
model = require("node-oauth2-server/examples/mongodb/model.js")
app = express()
app.configure ->
  app.oauth = oauthserver(
    model: model # See below for specification
    grants: ["password"]
    debug: true
  )
  app.use express.bodyParser() # REQUIRED
  return

app.all "/oauth/token", app.oauth.grant()
app.get "/", app.oauth.authorise(), (req, res) ->
  res.send "Secret area"
  return

app.use app.oauth.errorHandler()
app.listen 3000