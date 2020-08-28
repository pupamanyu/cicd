/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): xxxxxxxxxx_inserttable
Purpose: xxxxxxxxxx ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
                 Populate game event data for date partition.
*/


#  Remove existing date partitioned data before insert.
DELETE
    `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxx`
WHERE PARTITION_DATE = @dt_value;

CREATE TEMP FUNCTION get_delta(start_time STRING, end_time STRING) AS (
    CAST(ABS(TIMESTAMP_DIFF(TIMESTAMP(start_time) , TIMESTAMP(end_time), SECOND)) AS INT64)
    );

CREATE TEMP FUNCTION get_start_time(end_time STRING, duration INT64) AS (
    CAST(TIMESTAMP_SUB(TIMESTAMP(end_time), INTERVAL duration SECOND) AS STRING)
    );

INSERT `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxx` (game, realm_id, game_mode, game_type, game_id, puuid, player_journey_code, game_start_mmr,
                             game_end_mmr, game_start_opponent_mmr, game_end_opponent_mmr, game_end_rank,
                             game_start_rank, game_end_lp, game_start_lp, opponent_puuid, is_ai, is_ai_filled, deck_id,
                             faction1, faction2, faction3, equipped_board_id, equipped_board_name, equipped_guardian_id,
                             equipped_guardian_name, equipped_card_back_id, equipped_card_back_name,
                             game_start_time_utc, game_end_time_utc, player_end_time_utc, start_time_delta,
                             play_time_seconds, game_time_seconds, game_outcome, game_outcome_reason, total_turn_count,
                             round_count, order_of_play, datacenter, deployment, platform, country, country_code,
                             partition_hour, partition_date)


WITH game_start AS (
    SELECT `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxx`.*
         , ROW_NUMBER() OVER (PARTITION BY game_id, puuid
        ORDER BY game_start_time_utc ASC)     AS phase
    FROM `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxx`
)
   ,game_mode_type_map AS
    (SELECT 'AI' as raw_game_type, 'AI' as clean_game_type,'Constructed' as game_mode UNION ALL
     SELECT 'Play_AI',  'AI',   'Constructed' UNION ALL
     SELECT 'Player_AI',  'AI',   'Constructed' UNION ALL
     SELECT 'ForFun',  'Normal',   'Constructed' UNION ALL
     SELECT 'TryHard',  'Ranked',   'Constructed' UNION ALL
     SELECT 'TryHardPartialAlliances', 'Ranked',  'Constructed'  UNION ALL
     SELECT 'DevLimited',  'Normal',   'Test' UNION ALL
     SELECT 'DevTryHard',  'Normal',   'Test' UNION ALL
     SELECT 'DevForFun',  'Normal',   'Test' UNION ALL
     SELECT 'AutoSmokeTest',  'Normal',   'Test' UNION ALL
     SELECT 'Limited',  'Normal',   'Limited' UNION ALL
     SELECT 'tutorial',  'Normal',   'None' UNION ALL
     SELECT 'Practice',  'Challenge',   'Constructed' UNION ALL
     SELECT 'QueueDescriptor', 'Normal',  'Queue Descriptor' UNION ALL
     SELECT 'Ranked',  'Ranked',   'Constructed')

   ,game_end AS (
    SELECT xxxxxxxxxxxxxx.*
         , get_start_time(xxxxxxxxxxxxxx.game_end_time_utc,
                          xxxxxxxxxxxxxx.duration)                    AS game_start_time_utc
         , CASE

               WHEN regexp_contains(opponent_player_name,'npe_tutorials_Tutorial')

                   THEN concat('Tutorial',' ',REGEXP_EXTRACT(split(opponent_player_name,'_')[offset(3)], r"Tutorial([0-9]{1})"))
               WHEN regexp_contains(opponent_player_name,'Keywords')
                   THEN CONCAT(split(opponent_player_name,'_')[offset(3)],' ',
                               regexp_extract(split(opponent_player_name,'_')[offset(3)], '[0-9]'))
               ELSE game_mode_type_map.game_mode
        END                                                         AS game_mode

         , COALESCE(game_mode_type_map.clean_game_type, 'AI')          AS game_type
         , ROW_NUMBER() OVER (PARTITION BY game_id, puuid
        ORDER BY game_end_time_utc DESC)         AS phase
    FROM `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxx` xxxxxxxxxxxxxx
             LEFT JOIN game_mode_type_map ON
            xxxxxxxxxxxxxx.queue_name = game_mode_type_map.raw_game_type
)
SELECT 'Bacon' as game
     , IFNULL(COALESCE(game_end.realm_id, game_start.realm_id, queue_result.realm_id),'Unknown')       AS realm_id
     , IFNULL(game_end.game_mode,'Unknown') as game_mode
     , game_end.game_type AS game_type
     , game_end.game_id AS game_id
     , game_end.puuid AS puuid
     , 'Unknown'                                                                     AS player_journey_code
     , COALESCE(game_end.old_mmr, queue_result.mmr)                                  AS game_start_mmr
     , game_end.mmr                                                                  AS game_end_mmr
     , game_end.old_opponent_mmr                                                     AS game_start_opponent_mmr
     , game_end.opponent_mmr                                                         AS game_end_opponent_mmr
     , game_end.game_end_rank                                                        AS game_end_rank
     , game_end.game_start_rank                                                      AS game_start_rank
     , game_end.game_end_lp                                                          AS game_end_lp
     , game_end.game_start_lp                                                        AS game_start_lp
     , game_end.opponent_puuid AS opponent_puuid
     , IFNULL(COALESCE(game_end.is_ai, game_start.is_ai, queue_result.is_ai),false)                AS is_ai
     , IFNULL(COALESCE(game_end.is_ai_filled, game_start.is_ai_filled),false)                      AS is_ai_filled
     , IFNULL(COALESCE(game_end.deck_id, game_start.deck_id),'Unknown')                              AS deck_id
     , COALESCE(game_end.faction1, game_start.faction1)                              AS faction1
     , COALESCE(game_end.faction2, game_start.faction2)                              AS faction2
     , COALESCE(game_end.faction3, game_start.faction3)                              AS faction3
     , game_start.equipped_board_id                                                  AS equipped_board_id
     , COALESCE(
        NULLIF(
                game_start.equipped_board_name,
                "Unknown"
            ), boards.equipped_item_name,
        "Unknown"
    )                                                                             AS equipped_board_name
     , game_start.equipped_guardian_id                                               AS equipped_guardian_id
     , COALESCE(
        NULLIF(
                game_start.equipped_guardian_name,
                "Unknown"
            ), guardians.equipped_item_name,
        "Unknown"
    )                                                                             AS equipped_guardian_name
     , game_start.equipped_card_back_id                                              AS equipped_card_back_id
     , COALESCE(
        NULLIF(
                game_start.equipped_card_back_name,
                "Unknown"
            ),
        card_backs.equipped_item_name,
        "Unknown"
    ) AS equipped_card_back_name
     , COALESCE(game_start.game_start_time_utc, game_end.game_start_time_utc)        AS game_start_time_utc
     , game_end.game_end_time_utc                                                    AS game_end_time_utc
     , game_end.game_end_time_utc                                                    AS player_end_time_utc
     , get_delta(game_end.game_start_time_utc, game_start.game_start_time_utc)       AS start_time_delta
     , CAST(
        get_delta(COALESCE(game_start.game_start_time_utc,
                           game_end.game_start_time_utc),
                  game_end_time_utc)
    AS INT64)                                                                  AS play_time_seconds
     , CAST(
        get_delta(COALESCE(game_start.game_start_time_utc,
                           game_end.game_start_time_utc),
                  game_end_time_utc)
    AS INT64)                                                                  AS game_time_seconds
     , game_end.game_outcome AS game_outcome
     , game_end.game_outcome_reason AS game_outcome_reason
     , game_end.total_turn_count AS total_turn_count
     , game_end.round_count AS round_count
     , game_end.order_of_play AS order_of_play
     , COALESCE(game_end.datacenter, game_start.datacenter, queue_result.datacenter) AS datacenter
     , COALESCE(game_end.deployment, game_start.deployment, queue_result.deployment) AS deployment
     , COALESCE(game_end.runtime_platform, game_start.runtime_platform,
                queue_result.runtime_platform)                                       AS platform
     , 'Unknown'                                                                     AS country
     , IFNULL(xxxxxxxxxxxxxxxxxxxxx.country_code,'Unknown') AS country_code
     , 'Not Applicable'                                                              AS partition_hour
     , CAST(game_end.partition_date AS STRING) AS partition_date
FROM game_end
         LEFT JOIN game_start ON
            game_end.game_id = game_start.game_id
        AND game_end.puuid = game_start.puuid

         LEFT JOIN xxxxxx.xxxxxxxxxxxxxxxxxx AS queue_result ON
            game_end.game_id = queue_result.game_id
        AND game_end.puuid = queue_result.puuid

    -- Bacon DW Player Location Daily
         LEFT JOIN xxxxxx.xxxxxxxxxxxxxxxxxxxxx ON
        game_end.puuid = xxxxxxxxxxxxxxxxxxxxx.puuid

    -- Equipped Item Reference
         LEFT JOIN xxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx AS boards ON
        game_start.equipped_board_id = boards.equipped_item_id
         LEFT JOIN xxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx AS guardians ON
        game_start.equipped_guardian_id = guardians.equipped_item_id
         LEFT JOIN xxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx AS card_backs ON
        game_start.equipped_card_back_id = card_backs.equipped_item_id

WHERE game_start.phase = 1
  AND game_end.phase = 1