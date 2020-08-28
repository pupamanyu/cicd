/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): xxxxxxxxxxxxxxxxxx_inserttable
Purpose: xxxxxxxxxxxxxxxxxx ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
                 Populate xxxxxxxxxxxxxxxxxx data for date partition.
*/

#  Remove existing date partitioned data before insert.
DELETE
    `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxxxx`
WHERE
        PARTITION_DATE = @dt_value;

CREATE TEMP FUNCTION previous_partition_date(dt STRING) AS (
    DATE_SUB(PARSE_DATE('%Y-%m-%d',
    dt), INTERVAL 1 DAY)
    );

INSERT `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxxxx` (game_id, realm_id, puuid, is_ai, queue_name, queue_outcome, queue_timestamp_utc,
                                     queue_duration_seconds, mmr, runtime_platform, deployment, datacenter,
                                     partition_date)

WITH data as (
    SELECT game_id                                               AS game_id
         , realm_id                                              AS realm_id
         , player_info.puuid                                     AS puuid
         , player_info.is_ai                                     AS is_ai
         , CASE
               WHEN player_info.is_ai THEN 'AI'
               WHEN queue_name LIKE 'Practice%' THEN 'Practice'
               ELSE queue_name
        END                                                         queue_name
         , queue_outcome                                         AS queue_outcome
         , xxxxxx.to_isoformat(timestamp)                     AS queue_timestamp_utc
         , queue_time                                            AS queue_duration_seconds
         , CAST(match_making_rating AS INT64)                    AS mmr
         , xxxxxx.case_platform(player_info.runtime_platform) AS runtime_platform
         , metadata.scope.deployment                             AS deployment
         , metadata.scope.datacenter                             AS datacenter
         , DATE(_PARTITIONTIME)                                        as partition_date
    FROM `xxxxxxxxxxxxx.xxxxxxxxxxxx.queue_result`
    WHERE player_info.puuid NOT IN ('00000000-0000-0000-0000-000000000001', '_AI')
      AND (metadata.scope.deployment LIKE 'live%'
        OR metadata.scope.deployment LIKE '%svc')
      AND metadata.scope.deployment NOT LIKE 'staging%'
      AND DATE(_PARTITIONTIME) between previous_partition_date(@dt_value) and @dt_value)
SELECT row[OFFSET(0)].*
FROM (
         SELECT ARRAY_AGG(data ORDER BY game_id LIMIT 1) row
         FROM data
         GROUP BY game_id, puuid
     )

