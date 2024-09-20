use netflix 
go

--- Remove duplicates

select show_id , count(*)
from dbo.Netflix_dataset
group by show_id
having count(*) > 1  ---> no output --> set show_id a Primary Key


select title ,type ,count(*)
from dbo.Netflix_dataset
group by title ,type
having count(*)>1  


--- new table for director , listed_in , country , cast

select show_id,trim(value) as director
into netflix_director
from Netflix_dataset
cross apply string_split(director,',')


select show_id,trim(value) as genre
into netflix_genre
from Netflix_dataset
cross apply string_split(listed_in,',')


select show_id , trim(value) as country
into netflix_country
from Netflix_dataset
cross apply string_split(country ,',')


select show_id ,trim(value) as cast
into netflix_cast
from Netflix_dataset
cross apply string_split(cast , ',')


--populate missing values in country

insert into netflix_country
select show_id,data.country 
from netflix_dataset ndata inner join
(
select director,country
from netflix_country nc inner join netflix_director nd
on nc.show_id = nd.show_id
group by director,country
) data on data.director = ndata.director
where ndata.country is null


WITH cte AS (
    SELECT show_id,type,title,director,cast,country,date_added,release_year,rating,duration,listed_in,description,
           ROW_NUMBER() OVER (PARTITION BY title, type ORDER BY show_id) AS rn
    FROM Netflix_dataset
)

select show_id,type,title,cast(date_added as date) as date_added,release_year
,rating,case when duration is null then rating else duration end as duration,description   
into netflix_data
from cte 


"""
select * from Netflix_dataset where duration is null 

select show_id,type,title,
case when duration is null then rating else duration end as duration 
from Netflix_dataset

"""