const pool = require("../config/db");
const asyncHandler = require("../middleware/asyncHandler");

const ingestTelemetry = asyncHandler(async (req, res) => {
  const data = req.body;

  if (data.meterId) {
    await pool.query(
      `SELECT ingest_meter_data($1, $2, $3, $4)`,
      [
        data.meterId,
        data.kwhConsumedAc,
        data.voltage,
        data.timestamp
      ]
    );

    return res.json({ message: "Meter data ingested successfully" });
  }

  if (data.vehicleId) {
    await pool.query(
      `SELECT ingest_vehicle_data($1, $2, $3, $4, $5)`,
      [
        data.vehicleId,
        data.soc,
        data.kwhDeliveredDc,
        data.batteryTemp,
        data.timestamp
      ]
    );

    return res.json({ message: "Vehicle data ingested successfully" });
  }
});

module.exports = { ingestTelemetry };
