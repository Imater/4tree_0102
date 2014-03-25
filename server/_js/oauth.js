// Generated by CoffeeScript 1.6.3
(function() {
  var app, express, model, oauthserver;

  express = require("express");

  oauthserver = require("node-oauth2-server");

  model = require("node-oauth2-server/examples/mongodb/model.js");

  app = express();

  app.configure(function() {
    app.oauth = oauthserver({
      model: model,
      grants: ["password"],
      debug: true
    });
    app.use(express.bodyParser());
  });

  app.all("/oauth/token", app.oauth.grant());

  app.get("/", app.oauth.authorise(), function(req, res) {
    res.send("Secret area");
  });

  app.use(app.oauth.errorHandler());

  app.listen(3000);

}).call(this);
