const pool = require("../config/db");

const getPerformance = async (req, res) => {
  const { vehicleId } = req.params;

  try {
    const result = await pool.query(
      `SELECT * FROM get_vehicle_performance($1)`,
      [vehicleId]
    );

    return res.json(result.rows[0]);

  } catch (error) {
    console.error("Analytics Error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = { getPerformance };
