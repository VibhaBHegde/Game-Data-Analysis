CREATE DATABASE GameData;
SHOW DATABASES;
USE GameData;

SELECT * FROM sessions;

--  The date columns in the tables were changed from datetime to date
ALTER TABLE players
MODIFY install_date DATE;

SELECT * FROM players;

ALTER TABLE purchases
MODIFY purchase_date DATE;

SELECT * FROM purchases;

ALTER TABLE sessions
MODIFY session_date DATE;


SELECT * FROM sessions;

SELECT user_id, session_date, session_duration
FROM sessions
WHERE session_date >= '2025-01-01'
ORDER BY session_duration DESC;

select session_date, count(distinct user_id) as dau 
from sessions
group by session_date
ORDER BY session_date;

-- Paid vs Free users
SELECT 
	CASE 
		WHEN amount > 0 THEN 'Paid'
		ELSE 'Free'
	END AS user_type,
	COUNT(DISTINCT user_id) AS users
FROM purchases
GROUP BY user_type;

-- Joining players with purchases
SELECT p1.user_id, SUM(p2.amount) AS revenue
FROM players p1
LEFT JOIN purchases p2
ON p1.user_id = p2.user_id
GROUP BY p1.user_id
ORDER BY revenue DESC;

-- Ranking spenders
SELECT user_id, 
	SUM(amount) AS total_spend,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS ranks
FROM purchases
GROUP BY user_id;

-- D1 retention
SELECT 
	p.install_date, 
    COUNT(DISTINCT p.user_id) AS installs,
    COUNT(DISTINCT CASE WHEN s.session_date = p.install_date + 1 THEN p.user_id END) AS day1_users
FROM players p
LEFT JOIN sessions s
ON p.user_id = s.user_id
GROUP BY p.install_date;

-- ARPU
SELECT user_id, ROUND(SUM(amount) / COUNT(DISTINCT user_id), 2) AS arpu
FROM purchases
GROUP BY user_id
ORDER BY arpu DESC;

-- LTV by Acquisition Source
SELECT 
    p.acquisition_source,
    ROUND(SUM(pu.amount) / COUNT(DISTINCT p.user_id), 2) AS ltv
FROM players p
LEFT JOIN purchases pu
	ON p.user_id = pu.user_id
GROUP BY p.acquisition_source
ORDER BY ltv DESC;

-- D1 retention
SELECT p.install_date,
COUNT(DISTINCT p.user_id) AS installs,
COUNT(DISTINCT CASE WHEN s.session_date = DATE_ADD(p.install_date, INTERVAL 1 DAY) THEN p.user_id END) AS day1
FROM players p
LEFT JOIN sessions s
ON p.user_id = s.user_id
GROUP BY p.install_date;

-- Top 5 highest paying users
SELECT user_id, SUM(amount) AS high_payers
FROM purchases
GROUP BY user_id
ORDER BY high_payers DESC
LIMIT 5;

-- Cohort retention by install month
SELECT DATE_FORMAT(p.install_date, '%Y-%m') AS cohort,
COUNT(DISTINCT s.user_id) AS active_users
FROM players p
LEFT JOIN sessions s
ON p.user_id = s.user_id
GROUP BY cohort;






    



