/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): session_start_event_inserttable
Purpose: session_start_event ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
                 Populate session_start_event data for date partition.
*/

#  Remove existing date partitioned data before insert.
DELETE
    `lor-data-platform-dev-f369.gouri_dev.session_start_event`
WHERE
        PARTITION_DATE = @dt_value;

INSERT `lor-data-platform-dev-f369.gouri_dev.session_start_event` ( event_time_utc, puuid, ip_address, session_id, runtime_platform, realm_id, partition_date, country_code )

WITH
    t AS (
        SELECT
                NET.SAFE_IP_FROM_STRING(player_info.ip_address) & NET.IP_NET_MASK(4,
                                                                                  mask) network_bin,
                mask,
                gouri_dev.to_isoformat(metadata.timestamp) AS event_time_utc,
                player_info.puuid AS puuid,
                player_info.ip_address AS ip_address,
                player_info.session_id AS session_id,
                pramod_dev.platform_fx(player_info.runtime_platform) AS runtime_platform,
                gouri_dev.title(realm_id) AS realm_id,
                DATE(_PARTITIONTIME) AS partition_date
        FROM
            UNNEST(GENERATE_ARRAY(9,32)) mask,
            `lor-data-platform-dev-f369.lor_insights.session_start`,
            UNNEST( __envelope.stages ) AS b
        WHERE
                BYTE_LENGTH(NET.SAFE_IP_FROM_STRING(player_info.ip_address)) = 4
          AND DATE(_PARTITIONTIME) = @dt_value
          AND player_info.ip_address IS NOT NULL)

        SELECT
            CAST(t.event_time_utc AS STRING) AS event_time_utc,
            t.puuid AS puuid,
            t.ip_address AS ip_address,
            t.session_id AS session_id,
            t.runtime_platform AS runtime_platform,
            t.realm_id AS realm_id,
            t.partition_date AS partition_date,
            CASE
                WHEN ARRAY_LENGTH(REGEXP_EXTRACT_ALL(ip_address, r"((?:[0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,7}:|(?:[0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1,2}|(?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,3}|(?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,4}|(?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:(?:(?::[0-9a-fA-F]{1,4}){1,6})|:(?:(?::[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(?::[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(?:ffff(?::0{1,4}){0,1}:){0,1}(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(?:[0-9a-fA-F]{1,4}:){1,4}:(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")) > 0
                    THEN 'ipv6'
                ELSE
                    country_iso_code
                END country_code,
        FROM
            `lor-data-platform-dev-f369.gouri_dev.201806_geolite2_city_ipv4_locs` a
                JOIN
            t
            USING
                (network_bin,
                 mask)