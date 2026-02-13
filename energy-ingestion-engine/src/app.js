const express = require("express");
const cors = require("cors");
const ingestionRoutes = require("./routes/ingestionRoutes");
const analyticsRoutes = require("./routes/analyticsRoutes");
const errorHandler = require("./middleware/errorMiddleware");

const app = express();

app.use(cors());
app.use(express.json());


app.get("/", (req, res) => {
  res.json({ message: "Energy Ingestion Engine Running 🚀" });
});

app.use(errorHandler);


app.use("/v1/ingest", ingestionRoutes);
app.use("/v1/analytics", analyticsRoutes);


module.exports = app;
