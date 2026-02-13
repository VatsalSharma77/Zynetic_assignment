const express = require("express");
const router = express.Router();
const { ingestTelemetry } = require("../controllers/ingestionController");
const validateTelemetry = require("../middleware/validateMiddleware");

router.post("/", validateTelemetry, ingestTelemetry);

module.exports = router;
