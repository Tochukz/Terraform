var express = require("express");
var router = express.Router();

const users = [
  {
    name: "James Young",
  },
];
/* GET users listing. */
router.get("/list", function (req, res, next) {
  res.json(users);
});

module.exports = router;
