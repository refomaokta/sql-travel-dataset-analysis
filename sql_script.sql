-- number 1 (How many users are based on gender ?)
SELECT 
	gender,
    COUNT(gender) as total_users
FROM `travel_dataset_ datathon_2019`.users
GROUP BY gender
ORDER BY total_users DESC;

-- number 2 (How many users are based on age group ?)
WITH age_cat AS
(
SELECT 
	CASE WHEN age <= 12 THEN 'children'
		WHEN age <= 17 THEN 'teenager'
		WHEN age <= 64 THEN 'adults'
		ELSE 'older'
	END AS age_group
FROM `travel_dataset_ datathon_2019`.users
)
SELECT
	age_group,
    COUNT(age_group) AS total_users
FROM age_cat
GROUP BY age_group
ORDER BY total_users DESC;

-- number 3 (How many total users are based on the company ?)
SELECT 
	company,
    COUNT(company) as total_users
FROM `travel_dataset_ datathon_2019`.users
GROUP BY company
ORDER BY total_users DESC;

-- number 4 (Who are the list of user names based on the company ?)
SELECT 
	company,
    GROUP_CONCAT(name SEPARATOR ',') AS name_of_users
FROM `travel_dataset_ datathon_2019`.users
GROUP BY company;

-- number 5 (Which dates have the most flights ordered ?)
SELECT 
	date,
    COUNT(date) as total_flights_ordered
FROM `travel_dataset_ datathon_2019`.flights
GROUP BY date
ORDER BY total_flights_ordered DESC;

-- number 6 (Which month per each year has the most ordered flights ?)
WITH new_tab AS 
(
WITH extract_date AS
(
SELECT	YEAR(date) AS year_ordered,
		MONTH(date) AS month_ordered,
        DAY(date) AS day_ordered
FROM `travel_dataset_ datathon_2019`.flights
)
SELECT	year_ordered, month_ordered,
		COUNT(day_ordered) AS total_ordered_per_month
FROM extract_date
GROUP BY 1, 2
ORDER BY 3 DESC
)
SELECT	*,
		RANK() OVER(PARTITION BY year_ordered ORDER BY total_ordered_per_month DESC) AS ranking
FROM new_tab;

-- number 7 (Which agency flight has the most ordered based on route ?)
WITH total_agency_route_order AS
(
WITH group_route AS
(
SELECT
	CONCAT(origin, ' - ', destination) AS route,
    agency, date
FROM `travel_dataset_ datathon_2019`.flights
)
SELECT	route, agency,
		COUNT(date) AS total_order
FROM group_route 
GROUP BY 1, 2
ORDER BY 3 DESC
) 
SELECT	*,
		DENSE_RANK() OVER(PARTITION BY route ORDER BY total_order DESC) AS rank_agency
FROM total_agency_route_order;

-- number 8 (Which agency has ticket prices that are above average based on route and flight type ?)
WITH dif_price AS
(
WITH avg_price_tab AS
(
WITH price_type AS
(
WITH route_price AS
(
SELECT
		CONCAT(origin, '-', destination) AS route,
        agency, flightType, price
FROM `travel_dataset_ datathon_2019`.flights
)
SELECT	DISTINCT(route), flightType, agency, price,
		DENSE_RANK() OVER(PARTITION BY route, flightType ORDER BY price DESC) AS rank_price
FROM route_price
)
SELECT	route, flightType, agency, price,
		ROUND(AVG(price) OVER(PARTITION BY route, flightType),2) AS avg_price
FROM price_type
)
SELECT	*,
		ROUND((price - avg_price),2) AS diff_price
FROM avg_price_tab
)
SELECT	*,
		CASE WHEN diff_price > 0 THEN 'above average price'
			 ELSE 'below average price'
		END AS description
FROM dif_price;

-- number 9 (Which hotels have the most orders by user based on the destination place ?)
WITH num_place AS
(
SELECT	place, name,
		ROW_NUMBER () OVER(PARTITION BY place) AS num
FROM `travel_dataset_ datathon_2019`.hotels
)
SELECT	place, name, COUNT(name) AS total_ordered
FROM num_place
GROUP BY 1,2
ORDER BY 3 DESC; 

-- number 10 (Which hotel with the highest total days ordered ?)
SELECT place, name, SUM(days) AS total_days
FROM `travel_dataset_ datathon_2019`.hotels
GROUP BY 1, 2
ORDER BY 3 DESC;

-- number 11 (Which hotels have a higher rent price than average max rent price ?)
WITH max AS
(
SELECT place, name, MAX(price) AS max_price
FROM `travel_dataset_ datathon_2019`.hotels
GROUP BY 1,2
ORDER BY 3 DESC
)
SELECT *
FROM max
WHERE max_price > (SELECT AVG(price) FROM `travel_dataset_ datathon_2019`.hotels);

-- number 12 (Who are the top 3 of usernames with the most frequent flight order based on company ?)
WITH ranking AS
(
WITH total_order AS
(
SELECT	a.company, a.name,
		COUNT(date) AS total_ordered
FROM `travel_dataset_ datathon_2019`.users AS a
LEFT OUTER JOIN `travel_dataset_ datathon_2019`.flights AS b
ON a.code = b.userCode
GROUP BY 1,2
)
SELECT	company, name, total_ordered,
		DENSE_RANK() OVER(PARTITION BY company ORDER BY total_ordered DESC) AS rank_user_order
FROM total_order
) 
SELECT *
FROM ranking 
WHERE rank_user_order <= 3;

-- number 13 (Who are the top 3 of usernames with the highest total order first class type flight based on each agency ? )
WITH rank_3 AS
(
WITH total_order_firstclass AS
(
WITH order_type_flight AS
(
SELECT b.agency, b.flightType, a.name
FROM `travel_dataset_ datathon_2019`.users AS a
LEFT OUTER JOIN `travel_dataset_ datathon_2019`.flights AS b
ON a.code = b.userCode
WHERE flightType = 'firstClass'
)
SELECT	agency, name,
		COUNT(name) AS total_order
FROM order_type_flight
GROUP BY 1, 2
)
SELECT	*,
		DENSE_RANK() OVER (PARTITION BY agency ORDER BY total_order DESC) AS rank_user_first_class
FROM total_order_firstclass
)
SELECT *
FROM rank_3
WHERE rank_user_first_class < 4;

-- number 14 (How many times does each user book a hotel ?)
SELECT a.name, COUNT(b.date) AS total_booking_hotel
FROM `travel_dataset_ datathon_2019`.users AS a
LEFT OUTER JOIN `travel_dataset_ datathon_2019`.hotels AS b
ON a.code = b.userCode
GROUP BY 1
ORDER BY 2 DESC;

-- number 15 (How many total days were booked by each user ? )
SELECT a.name, SUM(b.days) AS total_days_booked_hotel
FROM `travel_dataset_ datathon_2019`.users AS a
LEFT OUTER JOIN `travel_dataset_ datathon_2019`.hotels AS b
ON a.code = b.userCode
GROUP BY 1
ORDER BY 2 DESC;








