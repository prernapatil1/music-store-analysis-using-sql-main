/**Who is the senior most employee based on job title?**/

select * from employee
order by levels desc
limit 1


/** which countries have the most invoices?**/ 


select count(*) as a, billing_country
from invoice
group by billing_country
order by a desc
limit 1


/** what are top 3 values of total invoices?**/

select * from invoice
order by total desc
limit 3

/** which city has the most customer ? we would like to throw a promotional music festival in the city 
we made the most money . Write a query that return one city that has the highest sum of invoice totals.
return both the city name and sum of all invoice total?**/

select sum(total) as invoice_total,billing_city as city
from invoice 
group by city
order by invoice_total desc
limit 1

/** who is the best customer? the customer who has the most money will be declared
the best customer.write a query that returns the person who has spent the most money.**/

select customer.customer_id , customer.first_name, customer.last_name ,sum(invoice.total) as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

/** write a query to return the email,first name, last name and genre of all rock music
listener, retunr your list orderd alphabetically by email starting with A?**/

SELECT DISTINCT email, first_name, last_name 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track.track_id 
    FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/** lets invite the artist who hav return the most rock musiic
in our dataset. arite the query that return the artist name
and total track count of the top 10 rock band**/

select artist.artist_id, artist.name,count(artist.artist_id)as no_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;


/** return all the track name that have a song length longer than the avereage song lengtht . return the name and milliseconds for each track.order by the songs with the desc order**/


select name, milliseconds from track 
where milliseconds >(
	select avg(milliseconds) as avg_track_length
	from track
)
order by milliseconds desc;


/** find how much amount spent by each customer on artist?
write a query to return customer name , artist name and total spent**/


with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,sum(invoice_line.unit_price*invoice_line.quantity)
	as total_sales from invoice_line
	join track on track.track_id=invoice_line.track_id
	join album on album.album_id=track.album_id
	join artist on artist.artist_id=album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select customer.customer_id,customer.first_name,customer.last_name,best_selling_artist.artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as amount_spent
from invoice
join customer on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join best_selling_artist on best_selling_artist.artist_id=album.artist_id
group by 1,2,3,4
order by 5 desc;

/**
we want to find out most popular music genre for each country.
we determine the most popular genre as the genre with hieghest amount of purchase.
write a query that return each country along with the top genre.
for countries where the maximum number of purchase is shared return all genre**/

with popular_genre as(
	select count(invoice_line.quantity) as purchase,customer.country,genre.name,genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity)desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1



/** write a query that determines the customer that has spent the most 
on music for each country.write a query that returns the country along with the customer and how much they spent.**/

with customer_with_country as (
	select customer.customer_id,first_name,last_name,billing_country,
	sum(total) as total_spending,row_number() over(partition by billing_country order by sum(total)desc) as RowNo
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc
)
select * from customer_with_country where RowNo <= 1