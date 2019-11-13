/* Question 1: What are the top/least rented(demanded) genres and what are what are their total sales? */

WITH t1 AS (SELECT c.name AS Genre, count(cu.customer_id) AS Total_rent_demand
            FROM category c
            JOIN film_category fc
            USING(category_id)
	    JOIN film f
            USING(film_id)
            JOIN inventory i
            USING(film_id)
            JOIN rental r
            USING(inventory_id)
            JOIN customer cu
            USING(customer_id)
            GROUP BY 1
            ORDER BY 2 DESC),
     t2 AS (SELECT c.name AS Genre, SUM(p.amount) AS total_sales
            FROM category c
            JOIN film_category fc
            USING(category_id)
            JOIN film f
            USING(film_id)
            JOIN inventory i
            USING(film_id)
            JOIN rental r
            USING(inventory_id)
            JOIN payment p
            USING(rental_id)
            GROUP BY 1
            ORDER BY 2 DESC)
SELECT t1.genre, t1.total_rent_demand, t2.total_sales
FROM t1
JOIN t2
ON t1.genre = t2.genre;

/* Question 2: Can we know how many distinct users have rented each genre?*/

SELECT c.name AS Genre, count(DISTINCT cu.customer_id) AS Total_rent_demand
FROM category c
JOIN film_category fc
USING(category_id)
JOIN film f
USING(film_id)
JOIN inventory i
USING(film_id)
JOIN rental r
USING(inventory_id)
JOIN customer cu
USING(customer_id)
GROUP BY 1
ORDER BY 2 DESC;

/* Question 3 :What is the Average rental rate for each genre? (from the highest to the lowest)*/

SELECT c.name AS genre, ROUND(AVG(f.rental_rate),2) AS Average_rental_rate
FROM category c
JOIN film_category fc
USING(category_id)
JOIN film f
USING(film_id)
GROUP BY 1
ORDER BY 2 DESC;

/* Question 4: How many rented films were returned late, early and on time?*/

WITH t1 AS (Select *, DATE_PART('day', return_date - rental_date) AS date_difference
            FROM rental),
t2 AS (SELECT rental_duration, date_difference,
              CASE
                WHEN rental_duration > date_difference THEN 'Returned early'
                WHEN rental_duration = date_difference THEN 'Returned on Time'
                ELSE 'Returned late'
              END AS Return_Status
          FROM film f
          JOIN inventory i
          USING(film_id)
          JOIN t1
          USING (inventory_id))
SELECT Return_status, count(*) As total_no_of _films
FROM t2
GROUP BY 1
ORDER BY 2 DESC;

/* Question 5: In which countries does Rent A Film have a presence in and what is the customer base in each country? What are the total sales in each country? (From most to least)*/

SELECT country, count(DISTINCT customer_id) AS customer_base, SUM(amount) AS total_sales
FROM country
JOIN city
USING(country_id)
JOIN address
USING(city_id)
JOIN customer
USING (address_id)
JOIN payment
USING(customer_id)
GROUP BY 1
ORDER BY 2 DESC;

/*Question 6:Who are the top 5 customers per total sales and can we get their detail just in case Rent A Film want to reward them?*/

WITH t1 AS (SELECT *, first_name || ' ' || last_name AS full_name
		    FROM customer)
SELECT full_name, email, address, phone, city, country, sum(amount) AS total_purchase_in_currency
FROM t1
JOIN address
USING(address_id)
JOIN city
USING (city_id)
JOIN country
USING (country_id)
JOIN payment
USING(customer_id)
GROUP BY 1,2,3,4,5,6
ORDER BY 7 DESC
LIMIT 5;

/*Question 7 : Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Can you provide a table with the movie titles 
and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all 
categories? Make sure to also indicate the category that these family-friendly movies fall into.

Direction for query formation: If you correctly split your data. You should only need the category, film_category, and film tables to answer this.

/*Query 7/*
SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
FROM film_category fc
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3
