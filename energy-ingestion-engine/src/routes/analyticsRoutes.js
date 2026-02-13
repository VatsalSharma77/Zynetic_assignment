const express = require("express");
const router = express.Router();
const { getPerformance } = require("../controllers/analyticsController");

router.get("/performance/:vehicleId", getPerformance);

module.exports = router;
