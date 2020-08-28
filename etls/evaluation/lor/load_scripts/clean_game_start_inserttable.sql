/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): clean_game_start_inserttable
Purpose: clean_game_start ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
                 Populate clean_game_start data for date partition.
*/

#  Remove existing date partitioned data before insert.
DELETE
    `lor-data-platform-dev-f369.gouri_dev.clean_game_start`
WHERE
        PARTITION_DATE = @dt_value;

CREATE TEMP FUNCTION previous_partition_date(dt STRING) AS (
    DATE_SUB(PARSE_DATE('%Y-%m-%d',
    dt), INTERVAL 1 DAY)
    );

INSERT `lor-data-platform-dev-f369.gouri_dev.clean_game_start` (game_id,
                                   realm_id,
                                   puuid,
                                   is_ai_filled,
                                   is_ai,
                                   equipped_board_id,
                                   equipped_board_name,
                                   equipped_guardian_id,
                                   equipped_guardian_name,
                                   equipped_card_back_id,
                                   equipped_card_back_name,
                                   queue_name,
                                   deck_id,
                                   game_start_time_utc,
                                   faction1,
                                   faction2,
                                   faction3,
                                   runtime_platform,
                                   deployment,
                                   datacenter,
                                   partition_date)

WITH data AS
         (SELECT game_info.game_id                                               AS game_id,
                 realm_id                                                        AS realm_id,
                 game_info.player_info.puuid                                     AS puuid,
                 game_info.is_ai_filled                                          AS is_ai_filled,
                 game_info.player_info.is_ai                                     AS is_ai,
                 COALESCE(NULLIF(equipped_board.loadout_id,
                                 null),
                          "Unknown")                                             AS equipped_board_id,
                 gouri_dev.title(COALESCE(NULLIF(equipped_board.loadout_name,
                                                 null),
                                          "Unknown"))                            AS equipped_board_name,
                 COALESCE(NULLIF(equipped_guardian.loadout_id,
                                 null),
                          "Unknown")                                             AS equipped_guardian_id,
                 gouri_dev.title(COALESCE(NULLIF(equipped_guardian.loadout_name,
                                                 null),
                                          "Unknown"))                            AS equipped_guardian_name,
                 COALESCE(NULLIF(equipped_cardback.loadout_id,
                                 null),
                          "Unknown")                                             AS equipped_card_back_id,
                 gouri_dev.title(COALESCE(NULLIF(equipped_cardback.loadout_name,
                                                 null),
                                          "Unknown"))                            AS equipped_card_back_name,
                 CASE
                     WHEN game_info.player_info.is_ai THEN 'AI'
                     WHEN game_info.queue_name LIKE 'Practice%' THEN 'Practice'
                     ELSE
                         game_info.queue_name
                     END                                                            queue_name,
                 deck_info.deck_id                                               AS deck_id,
                 gouri_dev.to_isoformat(start_time)                              AS game_start_time_utc,
                 gouri_dev.format_faction(deck_info.factions[SAFE_OFFSET(0)])    AS faction1,
                 gouri_dev.format_faction(deck_info.factions[SAFE_OFFSET(1)])    AS faction2,
                 gouri_dev.format_faction(deck_info.factions[SAFE_OFFSET(2)])    AS faction3,
                 gouri_dev.case_platform(game_info.player_info.runtime_platform) AS runtime_platform,
                 metadata.scope.deployment                                       AS deployment,
                 metadata.scope.datacenter                                       AS datacenter,
                 DATE(_PARTITIONTIME)                                                  AS partition_date
          FROM `lor-data-platform-dev-f369.lor_insights.game_start`
          WHERE game_info.player_info.puuid NOT IN ('00000000-0000-0000-0000-000000000001', '_AI')
            AND (metadata.scope.deployment LIKE 'live%'
              OR metadata.scope.deployment LIKE '%svc')
            AND metadata.scope.deployment NOT LIKE 'staging%'
            AND DATE(_PARTITIONTIME) between previous_partition_date(@dt_value) and @dt_value
         )

SELECT row[OFFSET(0)].*
FROM (
         SELECT ARRAY_AGG(data ORDER BY game_id LIMIT 1) row
         FROM data
         GROUP BY game_id, puuid, game_start_time_utc
     )