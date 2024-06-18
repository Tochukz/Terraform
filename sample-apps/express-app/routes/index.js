var express = require("express");
var router = express.Router();

/* GET home page. */
router.get("/", function (req, res, next) {
  const nodeEnv = process.env.NODE_ENV;
  res.render("index", {
    title: `Express application in ${nodeEnv} environment!`,
  });
});

module.exports = router;
