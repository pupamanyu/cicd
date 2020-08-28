/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): equipped_item_reference_daily_inserttable
Purpose: equipped_item_reference ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
                 Populate equipped item reference data for date partition.
*/


CREATE TEMP FUNCTION
    previous_partition_date(dt STRING) AS ( DATE_SUB(PARSE_DATE('%Y-%m-%d',
          dt), INTERVAL 1 DAY) );

CREATE TEMP FUNCTION title(str STRING) RETURNS STRING AS (
    (SELECT
    STRING_AGG(
    CONCAT(
    UPPER(
    SUBSTR(w, 1, 1)
    ),
    LOWER(
    SUBSTR(w,2)
    )
    ), ' ' ORDER BY pos
    )
    FROM
    UNNEST(SPLIT(str, " ")) w  WITH OFFSET pos
    )
    );

    WITH
      today_query AS (
      SELECT
        'Board' AS equipped_item_type,
        equipped_board.loadout_id AS equipped_item_id,
        CASE
          WHEN title(equipped_board.loadout_name) = "SUMMONER'S RIFT" THEN "Summoner's Rift"
        ELSE
        equipped_board.loadout_name
      END
        AS equipped_item_name,
        DATE('{{ params.dt_value }}') AS partition_date,
        start_time AS start_time
      FROM
          `{{params.source_project_id}}.{{params.source_dataset_name}}.game_start`
      WHERE
        _PARTITIONTIME = '{{ params.dt_value }}'
      UNION ALL
      SELECT
        'Guardian' AS equipped_item_type,
        equipped_guardian.loadout_id AS equipped_item_id,
        title(equipped_guardian.loadout_name) AS equipped_item_name,
        DATE('{{ params.dt_value }}') AS partition_date,
        start_time AS start_time
      FROM
        `lor-data-platform-dev-f369.lor_insights.game_start`
      WHERE
        _PARTITIONTIME = '{{ params.dt_value }}'
      UNION ALL
      SELECT
        'Card Back' AS equipped_item_type,
        equipped_cardback.loadout_id AS equipped_item_id,
        title(equipped_cardback.loadout_name ) AS equipped_item_name,
        DATE('{{ params.dt_value }}') AS partition_date,
        start_time AS start_time
      FROM
          `lor-data-platform-dev-f369.lor_insights.game_start`
      WHERE
        _PARTITIONTIME = '{{ params.dt_value }}'),
      equipment_map AS (
      SELECT
        *
      FROM
        today_query
      WHERE
        (equipped_item_id <> 'Unknown'
          AND equipped_item_name <> 'Unknown') ),
      prev_map AS (
      SELECT
        equipped_item_type,
        equipped_item_id,
        equipped_item_name,
        DATE('{{ params.dt_value }}') AS partition_date,
        '1900-01-01' AS start_time
      FROM
        `lor-data-platform-dev-f369.gouri_dev.equipped_item_reference_daily`
      WHERE
        partition_date = previous_partition_date('{{ params.dt_value }}') ),
      combined AS (
      SELECT
        *
      FROM
        equipment_map
      UNION ALL
      SELECT
        *
      FROM
        prev_map),
      equipped_item_reference_daily AS (
      SELECT
        first_row.equipped_item_name AS equipped_item_name,
        first_row.equipped_item_type AS equipped_item_type,
        first_row.equipped_item_id AS equipped_item_id,
        first_row.partition_date AS partition_date
      FROM (
        SELECT
          ARRAY_AGG(STRUCT(equipped_item_name,
              equipped_item_type,
              equipped_item_id,
              partition_date)
          ORDER BY
            start_time DESC
          LIMIT
            1)[safe_OFFSET(0)] AS first_row,
        FROM
          combined
        GROUP BY
          equipped_item_type,
          equipped_item_id,
          partition_date ) )
    SELECT
      *
    FROM
      equipped_item_reference_daily