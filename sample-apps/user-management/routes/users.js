var express = require("express");
var router = express.Router();

const users = [
  {
    userId: 1,
    fullname: "James Young",
  },
  {
    userId: 2,
    fullname: "Peter Theal",
  },
];

/* GET users listing. */
router.get("/", function (req, res, next) {
  res.json(users);
});

router.post("/create", function (req, res, next) {
  const fullname = req.body.fullname;
  const userId = users.length + 1;
  const newUser = { userId, fullname };
  users.push(newUser);
  return res.status(201).json(newUser);
});

module.exports = router;
