USE sakila;
#1a. Display the first and last names of all actors FROM the table actor.
SELECT first_name, last_name FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(concat_ws(" ", first_name, last_name)) AS 'Actor Name' FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

#2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

# Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;
 
 #2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so CREATE a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN description BLOB AFTER last_name;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS count FROM actor  GROUP BY last_name HAVING count > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

#5a. You cannot locate the schema of the address table. Which query would you use to re-CREATE it?
SHOW CREATE table address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT first_name, last_name, address
FROM staff
INNER JOIN address ON address.address_id = staff.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name,  SUM(amount) AS amount
FROM staff
INNER JOIN payment ON payment.staff_id = staff.staff_id
WHERE payment.payment_date LIKE '%2005-08%' GROUP BY last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use INNER JOIN.
SELECT title, COUNT(film_actor.actor_id) AS 'Total Actors'
FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id GROUP BY title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory.inventory_id) AS total_copies
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id WHERE film.title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) AS amount_paid
FROM customer
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY last_name ORDER BY last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unLIKEly resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title, name
FROM film
INNER JOIN language ON language.language_id = film.language_id
WHERE language.language_id = 1 AND film.title LIKE 'K%' OR film.title LIKE 'Q%' GROUP BY title;

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT title, first_name, last_name
FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id
INNER JOIN actor ON actor.actor_id = film_actor.actor_id  WHERE film.title = "Alone Trip";

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use JOINs to retrieve this information.
SELECT first_name, last_name, email
FROM customer
INNER JOIN address ON address.address_id = customer.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id WHERE country.country = "Canada";

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
INNER JOIN film_category ON film_category.film_id = film.film_id
INNER JOIN category ON category.category_id = film_category.category_id  WHERE category.name = "Family";

#7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(title) as rental_count
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id GROUP BY title ORDER BY rental_count DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT inventory.store_id, SUM(rental_rate) as rental_total
FROM inventory
INNER JOIN store ON store.store_id = inventory.store_id
INNER JOIN film ON film.film_id = inventory.film_id GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city, country
FROM store
INNER JOIN address ON address.address_id = store.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) as rental_totals
FROM rental
INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN film_category ON film_category.film_id = inventory.film_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
INNER JOIN category ON category.category_id = film_category.category_id GROUP BY category.name ORDER BY rental_totals DESC LIMIT 5;

#8a. In your new role as an executive, you would LIKE to have an easy way of viewing the Top five genres by gross revenue. Use the solution FROM the problem above to CREATE a view. If you haven't solved 7h, you can substitute another query to CREATE a view.
CREATE VIEW top_five_genres AS
SELECT name, SUM(amount) as rental_totals
FROM rental
INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN film_category ON film_category.film_id = inventory.film_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
INNER JOIN category ON category.category_id = film_category.category_id GROUP BY category.name ORDER BY rental_totals DESC LIMIT 5;

#8b. How would you display the view that you CREATEd in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
