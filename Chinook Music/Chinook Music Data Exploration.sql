-- What country has the most custommers?
Select country, count(CustomerId) as  no_of_customer
from customer
group by Country
Order by count(CustomerId) desc
limit 1;

-- Sales per country
select I.BillingCountry,
sum(IL.UnitPrice * IL.Quantity) as sales
from invoice I 
join invoiceline IL
on I.InvoiceId = IL.InvoiceId
group by 1
order by 2 desc;


-- Who are the top 5 customers?
select C.CustomerId,
concat(FirstName, ' ', LastName) as CustomersName,
C.Country,
sum(IL.UnitPrice * IL.Quantity) as AmountSpent
from customer C
join invoice I
on C.CustomerId = I.CustomerId
join invoiceline IL
on I.InvoiceId = IL.InvoiceId
Group by  C.CustomerId,
concat(FirstName, ' ', LastName),
C.Country
Order by sum(IL.UnitPrice * IL.Quantity) desc
limit 5;

-- What are the top 3 genre?
select G.Name, 
sum(IL.UnitPrice * IL.Quantity) as revenue
from customer C
join invoice I
on C.CustomerId = I.CustomerId
join invoiceline IL
on I.InvoiceId = IL.InvoiceId
join track T
on IL.TrackId = T.TrackId
join genre G
ON T.GenreId = G.GenreId
Group by G.Name;

-- Artists with the most rock music
select A.Name,
count(T.TrackId) as NoOfRock
from artist A
join album AL
on A.ArtistId = AL.ArtistId
join track T
on AL.AlbumId = T.AlbumId
join genre G
on T.genreId =  G.genreId
where G.Name = "Rock"
Group by A.Name
order by NoOfRock desc
limit 10;

-- Best selling artist and the customer who spent the most on the artist
with best_selling_artist as(
	select A.ArtistId, A.Name,
	sum(IL.UnitPrice * IL.Quantity) as Revenue
	from artist A
	join album AL
	on A.ArtistId = AL.ArtistId
	join track T
	on AL.AlbumId = T.AlbumId
	join invoiceline IL
	on IL.TrackId = T.TrackId
	group by A.ArtistId, A.Name
	order by Revenue desc
	limit 1
)

select bsa.name, sum(IL.UnitPrice * IL.Quantity) as AmountSpent, C.CustomerId,
concat(FirstName, ' ', LastName) as CustomersName
from customer C
join invoice I
on C.CustomerId = I.CustomerId
join invoiceline IL
on I.InvoiceId = IL.InvoiceId
join Track T
on T.TrackId = IL.TrackId
join album AL
on AL.AlbumId = T.AlbumId
join best_selling_artist bsa
on bsa.ArtistId = AL.ArtistId
group by 1,3,4
Order by 2 desc;

-- Average sales made by the artists
select avg(UnitPrice * Quantity) as SalesAverage
from invoiceline
 
 