use mavenmovies;

1.First Normal Form (1NF)
Violation Example: If there's a table like customer_phone with columns:

customer_id	name	phone_numbers
1	John Doe	1234567890, 9876543210
This violates 1NF because the phone_numbers column contains multiple values.

Normalization: Split it into two tables;

Customer Table:

customer_id	name
1	John Doe
Customer_Phone Table:

customer_id	phone_number
1	1234567890
1	9876543210;

2. Second Normal Form (2NF)
Table Example: rental_info (hypothetical)

rental_id	customer_id	customer_name	rental_date	movie_title
Violation: customer_name depends only on customer_id, not on the entire primary key (rental_id, customer_id);

Normalization Steps:

Rental Table:

rental_id	customer_id	rental_date
Customer Table:

customer_id	customer_name
Movie Table:

rental_id	movie_title

3. Third Normal Form (3NF)
Table Example: payment_details

payment_id	customer_id	customer_city	amount
Violation: customer_city depends on customer_id, not payment_id.

Normalization:

Payment Table:

payment_id	customer_id	amount
Customer Table:

customer_id	customer_city

;
......4. CTE Basics: Distinct actors and film counts;

WITH actor_film_count AS (
    SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id, a.first_name, a.last_name
)
SELECT first_name, last_name, film_count FROM actor_film_count;

...5.Recursive CTE;
WITH RECURSIVE category_hierarchy AS (
    SELECT category_id, name, NULL AS parent_id
    FROM category
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.category_id, c.name, ch.category_id
    FROM category c
    JOIN category_hierarchy ch ON c.parent_id = ch.category_id
)
SELECT * FROM category_hierarchy;

...6.CTE with Joins;
WITH film_info AS (
    SELECT f.title, l.name AS language, f.rental_rate
    FROM film f
    JOIN language l ON f.language_id = l.language_id
)
SELECT * FROM film_info;

...7. CTE for Aggregation- Total revenue per customer;

WITH customer_payments AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_revenue
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT * FROM customer_payments;

.....8. CTE with Window Functions: Rank films by rental duration;

WITH film_duration AS (
    SELECT title, rental_duration,
           RANK() OVER (ORDER BY rental_duration DESC) AS rank_CATEGORY
    FROM film
)
SELECT * FROM film_duration;

...9. CTE and Filtering: Customers with More Than Two Rentals;

WITH frequent_customers AS (
    SELECT customer_id, COUNT(*) AS rental_count
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(*) > 2
)
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customer c
JOIN frequent_customers fc ON c.customer_id = fc.customer_id;

...10. CTE for Date Calculations: Total Rentals Per Month;

WITH rentals_by_month AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(*) AS total_rentals
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT rental_month, total_rentals
FROM rentals_by_month
ORDER BY rental_month;

...11. CTE for Pivot Operations: Total Payments by Payment Method;

WITH payment_summary AS (
    SELECT 
        customer_id,
        SUM(CASE WHEN payment_method = 'Credit Card' THEN amount ELSE 0 END) AS credit_card_total,
        SUM(CASE WHEN payment_method = 'Cash' THEN amount ELSE 0 END) AS cash_total,
        SUM(CASE WHEN payment_method = 'Online' THEN amount ELSE 0 END) AS online_total
    FROM payment
    GROUP BY customer_id
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name,
    ps.credit_card_total,
    ps.cash_total,
    ps.online_total
FROM customer c
JOIN payment_summary ps ON c.customer_id = ps.customer_id;

....12.CTE and Self-Join: Pairs of Actors in the Same Film;

WITH actor_pairs AS (
    SELECT 
        fa1.actor_id AS actor1_id, 
        fa2.actor_id AS actor2_id, 
        fa1.film_id
    FROM film_actor fa1
    JOIN film_actor fa2 
        ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
)
SELECT 
    a1.first_name || ' ' || a1.last_name AS actor1, 
    a2.first_name || ' ' || a2.last_name AS actor2, 
    f.title
FROM actor_pairs ap
JOIN actor a1 ON ap.actor1_id = a1.actor_id
JOIN actor a2 ON ap.actor2_id = a2.actor_id
JOIN film f ON ap.film_id = f.film_id;

...13. CTE for Recursive Search: Employees Reporting to a Specific Manager;

WITH RECURSIVE staff_hierarchy AS (
    SELECT 
        staff_id, 
        first_name, 
        last_name, 
        manager_id
    FROM staff
    WHERE manager_id = 2 
    UNION ALL
    SELECT 
        s.staff_id, 
        s.first_name, 
        s.last_name, 
        s.manager_id
    FROM staff s
    JOIN staff_hierarchy sh ON s.manager_id = sh.staff_id
)
SELECT * FROM staff_hierarchy;

NOte- change Id according to needs;















