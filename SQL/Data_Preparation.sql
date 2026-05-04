WITH
	STANDARDIZED_DATE AS (
		SELECT
			ORDER_ID,
			CAST(
				CASE
					WHEN ORDER_DATE LIKE '% %' THEN REGEXP_REPLACE(
						SPLIT_PART(ORDER_DATE, ' ', 1),
						'(\d+)-(\d+)-(\d+)',
						'\2-\3-\1',
						'g'
					)
					ELSE REGEXP_REPLACE(ORDER_DATE, '(\d+)/(\d+)/(\d+)', '\2-\1-\3', 'g')
				END AS DATE
			) AS ORDER_DATE,
			CUSTOMER_ID,
			SALES
		FROM
			DATA.SUPERSTORE
	),
	CLEANED_DATA AS (
		SELECT
			*,
			EXTRACT(
				YEAR
				FROM
					ORDER_DATE
			) AS ORDER_YEAR
		FROM
			STANDARDIZED_DATE
	)
SELECT
	*
FROM
	CLEANED_DATA
WHERE
	ORDER_YEAR = 2017
	AND SALES IS NOT NULL;