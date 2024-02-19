const express = require("express");
const router = express.Router();

/* GET users listing. */
router.get("/", function (req, res, next) {
  res.send([
    {
      userId: 1,
      name: "John Smith",
    },
    {
      userId: 2,
      name: "Kelvin Hart",
    },
    // {
    //   userId: 3,
    //   name: "James Ford",
    // },
  ]);
});

module.exports = router;
