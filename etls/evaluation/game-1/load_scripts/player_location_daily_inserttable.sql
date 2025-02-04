/*
Copyright 2020 Google LLC.

This software is provided as-is, without warranty or representation
for any use or purpose. Your use of it is subject to your agreement with Google.

SQL Script(This one): xxxxxxxxxxxxxxxxxxxxx_inserttable
Purpose: xxxxxxxxxxxxxxxxxxxxx ETL Beam Pipeline

Input: Date
Expected Output: Delete existing date partitioned data.
                 Populate xxxxxxxxxxxxxxxxxxxxx data for date partition.
*/

#  Remove existing date partitioned data before insert.
DELETE
    `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxxxxxxx`
WHERE
        PARTITION_DATE = @dt_value;

CREATE TEMP FUNCTION previous_partition_date(dt STRING) AS (
    DATE_SUB(PARSE_DATE('%Y-%m-%d',
    dt), INTERVAL 1 DAY)
    );

INSERT `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxxxxxxx` ( puuid , user_logged_in , last_login_time_utc, country_code, partition_date )

WITH
    all_logins AS (
        SELECT
            puuid,
            "Yes" AS user_logged_in,
            event_time_utc AS last_login_time_utc,
            country_code,
            ip_address,
            partition_date
        FROM
        `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxxxxx`
        WHERE
                partition_date = @dt_value
          AND country_code <> 'Unknown'
        UNION ALL
        SELECT
            puuid,
            "No" AS user_logged_in,
            last_login_time_utc,
            country_code,
            '0' AS ip_address,
            @dt_value AS partition_date
        FROM
        `xxxxxxxxxxxxx.xxxxxx.xxxxxxxxxxxxxxxxxxxxx`
        WHERE
                partition_date = previous_partition_date(@dt_value)),
        ranked_logins AS (
        SELECT
            puuid,
            user_logged_in,
            last_login_time_utc,
            country_code,
            partition_date,
            ROW_NUMBER() OVER (PARTITION BY puuid ORDER BY last_login_time_utc DESC,
                country_code DESC,
                ip_address DESC ) AS rank
        FROM
        all_logins )
        SELECT
        puuid,
        user_logged_in,
        last_login_time_utc,
        country_code,
        partition_date
        FROM
        ranked_logins
        WHERE
                rank = 1