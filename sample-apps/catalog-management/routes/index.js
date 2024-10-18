var express = require("express");
var router = express.Router();

const categories = [
  {
    categoryId: 1,
    name: "Physical Science",
  },
  {
    categoryId: 2,
    name: "Live Science",
  },
];

router.get("/", function (req, res, next) {
  console.log("root url", req.url);
  res.render("index", { title: "Catalog Management Server" });
});

module.exports = router;
