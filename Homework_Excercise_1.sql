-- / *************************************************
-- @author: Megan Gray
-- @date: 2018-11-01
-- Unit 09 - SQL Homework
-- / *************************************************

-- Refer to README.md file for original homework instructions for this assignment.

-- Specify which database to use when starting SQL
USE sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT DISTINCT first_name, last_name 
    from actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name'.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' from actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id
    ,first_name, 
    last_name FROM actor
    WHERE first_name 
    IN ("joe");

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id
    ,first_name, 
    last_name FROM actor
    WHERE last_name 
    LIKE ("%gen%");

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id
    ,first_name, 
    last_name FROM actor
    WHERE last_name 
    LIKE ("%LI%")
    ORDER BY last_name ASC;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
    FROM country
    WHERE country 
    IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
    ADD COLUMN description BLOB;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) > 1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT actor_id, first_name, last_name from actor
where first_name like "GRO%";
-- ***** Groucho Williams is actor_id #172. Write query to change name from Groucho to Harpo.
UPDATE actor
Set first_name = 'HARPO'
Where actor_id = 172;

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- ***** Need to remove safe update mode in order to allow code to run.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
Set first_name = 'GROUCHO'
Where first_name = 'HARPO';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address ON staff.address_id=address.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, sum(payment.amount) AS 'Total Amount', payment_date
FROM staff
INNER JOIN payment ON staff.staff_id=payment.staff_id
WHERE YEAR(payment.payment_date)=2005 AND MONTH(payment.payment_date)=08
Group by staff.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT count(film_actor.actor_id) AS 'Number of Actors', film.title AS 'Films'
FROM film_actor
INNER JOIN film ON film_actor.film_id=film.film_id
Group by film.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(inventory.film_id) AS 'Available Copies', film.title AS 'Selected Film'
FROM film
INNER JOIN inventory ON film.film_id=inventory.film_id
WHERE film.title LIKE "Hunchback Impossible";

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount) AS 'Total Amount Paid'
FROM customer
JOIN payment ON customer.customer_id=payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
Select film.title, language.name
from film
INNER JOIN language ON film.language_id=language.language_id
Where film.title LIKE "K%"
   OR film.title LIKE "Q%";

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
Select first_name,last_name
From actor
Where actor_id in
    (select actor_id from film_actor
    where film_id in
        (select film_id from film
         where title like 'Alone Trip')
         );

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country FROM customer
INNER JOIN address ON customer.address_id=address.address_id
INNER JOIN city ON address.city_id=city.city_id
INNER JOIN country ON city.country_id=country.country_id
WHERE country.country = 'canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT film.film_id, title FROM film
INNER JOIN film_category on film_category.film_id=film.film_id
INNER JOIN  category on category.category_id=film_category.category_id
WHERE category.name = 'Family';

-- * 7e. Display the most frequently rented movies in descending order.
SELECT store.store_id, sum(amount) from store
INNER JOIN inventory on store.store_id=inventory.store_id
INNER JOIN rental on inventory.inventory_id=rental.inventory_id
INNER JOIN payment on rental.rental_id=payment.rental_id
GROUP BY store.store_id;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, sum(amount) from store
INNER JOIN inventory on store.store_id=inventory.store_id
INNER JOIN rental on inventory.inventory_id=rental.inventory_id
INNER JOIN payment on rental.rental_id=payment.rental_id
GROUP BY store.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country from store
INNER JOIN address on store.address_id=address.address_id
INNER JOIN city on address.city_id=city.city_id
INNER JOIN country on city.country_id=country.country_id;

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, sum(amount) from payment
INNER JOIN rental ON payment.rental_id=rental.rental_id
INNER JOIN inventory ON rental.inventory_id=inventory.inventory_id
INNER JOIN film_category ON inventory.film_id=film_category.film_id
INNER JOIN category ON film_category.category_id=category.category_id
GROUP BY name
ORDER BY sum(amount) desc
LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW
top_five_grossing_genres as 
SELECT category.name, sum(amount) from payment
INNER JOIN rental ON payment.rental_id=rental.rental_id
INNER JOIN inventory ON rental.inventory_id=inventory.inventory_id
INNER JOIN film_category ON inventory.film_id=film_category.film_id
INNER JOIN category ON film_category.category_id=category.category_id
GROUP BY name
ORDER BY sum(amount) desc
LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_grossing_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_grossing_genres;