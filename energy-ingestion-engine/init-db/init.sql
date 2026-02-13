-- TABLES--

CREATE TABLE meter_telemetry (
    id BIGSERIAL PRIMARY KEY,
    meter_id VARCHAR(50) NOT NULL,
    kwh_consumed_ac NUMERIC(10,2),
    voltage NUMERIC(6,2),
    timestamp TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_meter_id_timestamp
ON meter_telemetry (meter_id, timestamp DESC);


CREATE TABLE vehicle_telemetry (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id VARCHAR(50) NOT NULL,
    soc NUMERIC(5,2),
    kwh_delivered_dc NUMERIC(10,2),
    battery_temp NUMERIC(5,2),
    timestamp TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_vehicle_id_timestamp
ON vehicle_telemetry (vehicle_id, timestamp DESC);


CREATE TABLE live_meter_status (
    meter_id VARCHAR(50) PRIMARY KEY,
    kwh_consumed_ac NUMERIC(10,2),
    voltage NUMERIC(6,2),
    last_updated TIMESTAMPTZ
);

CREATE TABLE live_vehicle_status (
    vehicle_id VARCHAR(50) PRIMARY KEY,
    soc NUMERIC(5,2),
    kwh_delivered_dc NUMERIC(10,2),
    battery_temp NUMERIC(5,2),
    last_updated TIMESTAMPTZ
);

--FUNCTIONS--

CREATE OR REPLACE FUNCTION public.get_vehicle_performance(
	p_vehicle_id character varying)
    RETURNS TABLE(total_ac numeric, total_dc numeric, efficiency_ratio numeric, avg_battery_temp numeric) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN

    RETURN QUERY
    WITH vehicle_data AS (
        SELECT 
            SUM(kwh_delivered_dc) AS total_dc,
            AVG(battery_temp) AS avg_temp
        FROM vehicle_telemetry
        WHERE vehicle_id = p_vehicle_id
        AND timestamp >= NOW() - INTERVAL '24 HOURS'
    ),
    meter_data AS (
        SELECT 
            SUM(kwh_consumed_ac) AS total_ac
        FROM meter_telemetry
        WHERE timestamp >= NOW() - INTERVAL '24 HOURS'
    )
    SELECT
        COALESCE(m.total_ac, 0),
        COALESCE(v.total_dc, 0),
        CASE 
            WHEN COALESCE(m.total_ac,0) > 0 
            THEN v.total_dc / m.total_ac
            ELSE 0
        END,
        v.avg_temp
    FROM vehicle_data v
    CROSS JOIN meter_data m;

END;
$BODY$;


CREATE OR REPLACE FUNCTION public.ingest_vehicle_data(
	p_vehicle_id character varying,
	p_soc numeric,
	p_kwh_delivered_dc numeric,
	p_battery_temp numeric,
	p_timestamp timestamp with time zone)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN

    INSERT INTO vehicle_telemetry (
        vehicle_id,
        soc,
        kwh_delivered_dc,
        battery_temp,
        timestamp
    )
    VALUES (
        p_vehicle_id,
        p_soc,
        p_kwh_delivered_dc,
        p_battery_temp,
        p_timestamp
    );

    INSERT INTO live_vehicle_status (
        vehicle_id,
        soc,
        kwh_delivered_dc,
        battery_temp,
        last_updated
    )
    VALUES (
        p_vehicle_id,
        p_soc,
        p_kwh_delivered_dc,
        p_battery_temp,
        p_timestamp
    )
    ON CONFLICT (vehicle_id)
    DO UPDATE SET
        soc = EXCLUDED.soc,
        kwh_delivered_dc = EXCLUDED.kwh_delivered_dc,
        battery_temp = EXCLUDED.battery_temp,
        last_updated = EXCLUDED.last_updated;

END;
$BODY$;


CREATE OR REPLACE FUNCTION public.ingest_meter_data(
	p_meter_id character varying,
	p_kwh_consumed_ac numeric,
	p_voltage numeric,
	p_timestamp timestamp with time zone)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN

    INSERT INTO meter_telemetry (
        meter_id,
        kwh_consumed_ac,
        voltage,
        timestamp
    )
    VALUES (
        p_meter_id,
        p_kwh_consumed_ac,
        p_voltage,
        p_timestamp
    );

    INSERT INTO live_meter_status (
        meter_id,
        kwh_consumed_ac,
        voltage,
        last_updated
    )
    VALUES (
        p_meter_id,
        p_kwh_consumed_ac,
        p_voltage,
        p_timestamp
    )
    ON CONFLICT (meter_id)
    DO UPDATE SET
        kwh_consumed_ac = EXCLUDED.kwh_consumed_ac,
        voltage = EXCLUDED.voltage,
        last_updated = EXCLUDED.last_updated;

END;
$BODY$;


