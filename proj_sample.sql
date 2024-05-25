-- go through the columns 
SELECT * FROM proj_sam.layoffs;

-- create copy of the table to work on it
create table layoffs2 Like layoffs;

-- insert values from original data to here
insert into layoffs2 select * from layoffs;

-- check whether everything is updated
select * from layoffs2;

-- step 1 removing duplicates by providing unique row numbers , partition by all columns
select * , ROW_NUMBER()
 over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as rownum
from layoffs2;

-- identify the duplicates using row number as duplicates
select * from 
(select * , ROW_NUMBER()
 over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as rownum
from layoffs2) as duplicates
where rownum > 1;

-- checking whether it is duplicate
select * from layoffs2 where company = "casper";

-- tried to delete duplicates on same table , so creating new one with rownum and deleting it.
CREATE TABLE `layoffs3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row` int
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 INSERT INTO `proj_sam`.`layoffs3`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row`)
select `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
ROW_NUMBER() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
from layoffs2;
select * from layoffs3;

-- deleting duplucates
delete from layoffs3 where `row`>2;

-- step 2 standardizing data
-- finding and fixing issue
-- trimming extra spaces
-- finding issues in categories
-- formatting data types
select * from layoffs3;

-- trimming extra spaces , from every column

select trim(company), trim(location), trim(industry), trim(country) from layoffs3;
update layoffs3 set company = trim(company), industry=trim(industry), country=trim(country);

-- finding issues in categories -country

select distinct country from layoffs3 order by country;
-- 2 united states with . lets trim it ;
select trim(trailing '.' from country) from layoffs3;

update layoffs3 set country = trim(trailing '.' from country);
select distinct country from layoffs3 order by country;

-- formatting data types of date- text into date

select * from layoffs3;
alter table layoffs3 modify column `date` date;
select * from layoffs3;







