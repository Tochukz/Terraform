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
  return res.json(categories);
});

router.post("/create", (req, res, next) => {
  const categoryName = req.body.categoryName;
  const categoryId = categories.length + 1;
  const newCategory = { categoryId, categoryName };
  categories.push(newCategory);
  return res.status(201).json(newCategory);
});

module.exports = router;
