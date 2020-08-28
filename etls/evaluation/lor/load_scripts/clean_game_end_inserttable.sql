/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): xxxxxxxxxxxxxx_inserttable
Purpose: xxxxxxxxxxxxxx ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
               Populate xxxxxxxxxxxxxx data for date partition.
*/

#  Remove existing date partitioned data before insert.
DELETE
    `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxx`
WHERE
        PARTITION_DATE = @dt_value;
CREATE TEMP FUNCTION
  previous_partition_date(dt STRING) AS ( DATE_SUB(PARSE_DATE('%Y-%m-%d',
        dt), INTERVAL 1 DAY) );
INSERT
    `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxx` (game_id,
                                                           realm_id,
                                                           puuid,
                                                           is_ai_filled,
                                                           is_ai,
                                                           queue_name,
                                                           deck_id,
                                                           faction1,
                                                           faction2,
                                                           faction3,
                                                           old_mmr,
                                                           mmr,
                                                           opponent_puuid,
                                                           opponent_player_name,
                                                           old_opponent_mmr,
                                                           opponent_mmr,
                                                           game_start_rank,
                                                           game_end_rank,
                                                           game_start_lp,
                                                           game_end_lp,
                                                           game_end_time_utc,
                                                           duration,
                                                           total_turn_count,
                                                           round_count,
                                                           game_outcome,
                                                           game_outcome_reason,
                                                           order_of_play,
                                                           runtime_platform,
                                                           deployment,
                                                           datacenter,
                                                           partition_date)
WITH
    max_times AS (
        SELECT
            game_info.player_info.puuid AS puuid,
            MAX(end_time) AS max_time
        FROM
            `xxxxxxxxxxxxx.xxxxxxxxxxxx.game_end`
        WHERE
                DATE(_PARTITIONTIME) = previous_partition_date(@dt_value)
        GROUP BY
            game_info.player_info.puuid),
    previous_ranks AS (
        SELECT
            opponent_game_info.player_info.puuid,
            COALESCE(xxxxxx.format_rank_division(self_rank_update.old_tier.name,
                                                    self_rank_update.old_division),
                     "Unknown") AS old_rank,
            COALESCE(xxxxxx.format_rank_division(self_rank_update.new_tier.name,
                                                    self_rank_update.new_division),
                     "Unknown") AS rank,
    CAST( COALESCE ( self_rank_update.old_league_point,
    -1 ) AS INT64 ) AS old_lp,
    CAST( COALESCE ( self_rank_update.new_league_point,
    -1 ) AS INT64 ) AS lp,
    xxxxxx.title( COALESCE ( SPLIT( opponent_rank_update.old_tier.name, "_")[ SAFE_OFFSET (1)],
    "Unknown" ) ) AS old_opponent_rank,
    xxxxxx.title( COALESCE ( SPLIT( opponent_rank_update.new_tier.name, "_")[ SAFE_OFFSET (1)],
    "Unknown" ) ) AS opponent_rank,
    CAST( COALESCE ( opponent_rank_update.old_league_point,
    -1 ) AS INT64 ) AS old_opponent_lp,
    CAST( COALESCE ( opponent_rank_update.new_league_point,
    -1 ) AS INT64 ) AS opponent_lp
FROM
    `xxxxxxxxxxxxx.xxxxxxxxxxxx.game_end` AS ge
    INNER JOIN
    max_times AS mt
ON
    mt.puuid = game_info.player_info.puuid
    AND mt.max_time = end_time
WHERE
    DATE (_PARTITIONTIME) = previous_partition_date(@dt_value)
  AND opponent_game_info.queue_name = 'TryHard' ),
    DATA AS (
SELECT
    game_info.game_id AS game_id,
    realm_id AS realm_id,
    game_info.player_info.puuid AS puuid,
    game_info.is_ai_filled AS is_ai_filled,
    game_info.player_info.is_ai AS is_ai,
    CASE
    WHEN game_info.player_info.is_ai THEN 'AI'
    WHEN game_info.queue_name LIKE 'Practice%' THEN 'Practice'
    ELSE
    game_info.queue_name
    END
    queue_name,
    deck_info.deck_id AS deck_id,
    xxxxxx.format_faction(deck_info.factions[ SAFE_OFFSET (0)]) AS faction1,
    xxxxxx.format_faction(deck_info.factions[ SAFE_OFFSET (1)]) AS faction2,
    xxxxxx.format_faction(deck_info.factions[ SAFE_OFFSET (2)]) AS faction3,
    CAST( self_rating_update.old_match_making_rating AS INT64) AS old_mmr,
    CAST( COALESCE ( self_rating_update.new_match_making_rating,
    match_making_rating ) AS INT64) AS mmr,
    opponent_game_info.player_info.puuid AS opponent_puuid,
    opponent_game_info.player_info.player_name AS opponent_player_name,
    CAST( opponent_rating_update.old_match_making_rating AS INT64) AS old_opponent_mmr,
    CAST( COALESCE ( opponent_rating_update.new_match_making_rating,
    match_making_rating ) AS INT64) AS opponent_mmr,
    CASE
    WHEN game_info.queue_name = 'TryHard' THEN COALESCE ( xxxxxx.format_rank_division( self_rank_update.old_tier.name, self_rank_update.old_division ), pr.old_rank, "Unknown" )
    ELSE
    "Not Applicable"
    END
    AS game_start_rank,
    CASE
    WHEN game_info.queue_name = 'TryHard' THEN COALESCE ( xxxxxx.format_rank_division( self_rank_update.old_tier.name, self_rank_update.new_division ), pr.rank, "Unknown" )
    ELSE
    "Not Applicable"
    END
    AS game_end_rank,
    CAST( COALESCE ( self_rank_update.old_league_point,
    pr.old_lp,
    -1 ) AS INT64 ) AS game_start_lp,
    CAST( COALESCE ( self_rank_update.new_league_point,
    pr.lp,
    -1 ) AS INT64 ) AS game_end_lp,
    xxxxxx.to_isoformat(end_time) AS game_end_time_utc,
    game_total_time_in_seconds AS duration,
    turn_count_game_total AS total_turn_count,
    round_count AS round_count,
    CASE
    WHEN game_outcome = 'win' THEN 'Victory'
    WHEN game_outcome = 'loss' THEN 'Defeat'
    ELSE
    'Tie'
    END
    AS game_outcome,
    xxxxxx.title( REGEXP_REPLACE( game_outcome_reason, '-', ' ')) AS game_outcome_reason,
    order_of_play AS order_of_play,
    xxxxxx.case_platform( game_info.player_info.runtime_platform ) AS runtime_platform,
    metadata.scope.deployment AS deployment,
    metadata.scope.datacenter AS datacenter,
    DATE(_PARTITIONTIME) AS partition_date
FROM
    `xxxxxxxxxxxxx.xxxxxxxxxxxx.game_end`
    LEFT JOIN
    previous_ranks AS pr
ON
    pr.puuid = opponent_game_info.player_info.puuid
WHERE
    game_info.player_info.puuid NOT IN ('00000000-0000-0000-0000-000000000001',
    '_AI')
  AND ( metadata.scope.deployment LIKE 'live%'
   OR metadata.scope.deployment LIKE '%svc')
  AND metadata.scope.deployment NOT LIKE 'staging%'
  AND DATE (_PARTITIONTIME) BETWEEN previous_partition_date(@dt_value)
  AND @dt_value )
SELECT
    ROW[
        OFFSET
            (0)].*
FROM (
         SELECT
             ARRAY_AGG(DATA
                 ORDER BY
      game_id
    LIMIT
      1) ROW
         FROM
             DATA
         GROUP BY
             game_id,
             puuid,
             game_end_time_utc )