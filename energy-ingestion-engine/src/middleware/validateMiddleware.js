const Joi = require("joi");

const meterSchema = Joi.object({
  meterId: Joi.string().required(),
  kwhConsumedAc: Joi.number().required(),
  voltage: Joi.number().required(),
  timestamp: Joi.date().iso().required()
});

const vehicleSchema = Joi.object({
  vehicleId: Joi.string().required(),
  soc: Joi.number().min(0).max(100).required(),
  kwhDeliveredDc: Joi.number().required(),
  batteryTemp: Joi.number().required(),
  timestamp: Joi.date().iso().required()
});

const validateTelemetry = (req, res, next) => {
  const body = req.body;

  if (body.meterId) {
    const { error } = meterSchema.validate(body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
  }

  else if (body.vehicleId) {
    const { error } = vehicleSchema.validate(body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
  }

  else {
    return res.status(400).json({
      error: "Payload must contain meterId or vehicleId"
    });
  }

  next();
};

module.exports = validateTelemetry;
