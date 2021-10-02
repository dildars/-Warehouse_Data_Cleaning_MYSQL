/*
Cleaning Data  
 */
 -- 1. Fetch whole store information
 
 SELECT * 
 FROM WareHouse_Details;
 
--------------------------------------------------------------------------------------------------------------------------
-- 2. Standardize Date Format 
 
 SELECT
	purchase_date, STR_TO_DATE(purchase_date, "%d-%b-%y")
FROM
	WareHouse_Details;

-- Update table using correct date format

UPDATE
	WareHouse_Details
SET
	purchase_date = STR_TO_DATE(purchase_date, "%d-%b-%y");
 
--------------------------------------------------------------------------------------------------------------------------

-- 3. Populate Warehouse Address data using Store_TAN_Number

SELECT 	
	x.Store_Tan_number, x.store_address,
	y.Store_Tan_number, y.store_address,
	IFNULL(x.store_address, y.store_address) 
FROM 
	WareHouse_Details x 
	JOIN WareHouse_Details y 
	ON x.Store_Tan_number = y.Store_Tan_number AND
	x.Store_Unique_ID <> y.Store_Unique_ID 
WHERE 
	x.store_address IS NULL ;

 -- 4. Update Warehouse Address data using Store_TAN_Number

 UPDATE
	WareHouse_Details x 
	JOIN WareHouse_Details y 
	ON x.Store_Tan_number = y.Store_Tan_number AND
	x.Store_Unique_ID <> y.Store_Unique_ID 
SET
	x.store_address = IFNULL(x.store_address, y.store_address)
WHERE 
	x.store_address IS NULL;

--------------------------------------------------------------------------------------------------------------------------
-- 5. Breaking out Address into Individual Columns (Address, City) 
 
SELECT
	SUBSTRING_INDEX(store_address, ',', 1) as Address,
	SUBSTRING_INDEX(store_address, ',', -1) as City
FROM 
	WareHouse_Details ;

ALTER TABLE 
	WareHouse_Details 
    Add City varchar(25) After store_address;

UPDATE 
	WareHouse_Details
SET
	City= SUBSTRING_INDEX(store_address, ',', -1);

UPDATE 
	WareHouse_Details
SET
	Store_Address= SUBSTRING_INDEX(store_address, ',', 1);


SELECT 
	* 
FROM
	WareHouse_Details;

--------------------------------------------------------------------------------------------------------------------------
-- 6. Change Y and N to Yes and No in "Sold as Vacant" field

-- Count Y, N, Yes and No in "Sold as Vacant" field
Select 
	Distinct(Sold_As_Vacant), Count(Sold_As_Vacant)
From 
	WareHouse_Details
Group by 
	Sold_As_Vacant
order by 
	Store_unique_id desc;


SELECT Sold_As_Vacant,
CASE
	WHEN Sold_As_Vacant ='Y' THEN 'YES'
    WHEN Sold_As_Vacant ='N' THEN 'NO'
    ELSE Sold_As_Vacant
    END
FROM WareHouse_Details;

-- Update Sold_As_Vacant column using SWITCH

UPDATE WareHouse_Details
SET Sold_As_Vacant =
		CASE
			WHEN Sold_As_Vacant ='Y' THEN 'YES'
			WHEN Sold_As_Vacant ='N' THEN 'NO'
			ELSE Sold_As_Vacant
		END;

--------------------------------------------------------------------------------------------------------------------------
-- 7. Create Temporary Table to delete Rows

CREATE
TEMPORARY TABLE 
	Warehouse_temp (
	SELECT * 
    FROM WareHouse_Details);

-- To check whether the data is stored in temporary table or not

SELECT * 
FROM 
	Warehouse_temp;

--------------------------------------------------------------------------------------------------------------------------
-- 8. Remove Duplicates
-- Count how many rows are duplicate in this SQL

SELECT 
	Store_unique_id, Store_TAN_number, COUNT(Store_unique_id)  
FROM 
	WareHouse_Details  
GROUP BY 
	Store_unique_id  
HAVING 
	COUNT(Store_unique_id) > 1;  

-- Cross check the duplicate data, example store id = 38748

SELECT *
FROM 
	WareHouse_Details 
WHERE store_unique_id ='38748';

-- Delete Duplicate Rows

DELETE S3 FROM WareHouse_Details AS S3  
INNER JOIN WareHouse_Details AS S4   
WHERE S3.id < S4.id and S3.Store_unique_id  = S4.Store_unique_id AND S3.Store_TAN_number = S4.Store_TAN_number;

--------------------------------------------------------------------------------------------------------------------------
-- 8. Drop Unwanted Column

SELECT * 
FROM WareHouse_Details;

ALTER TABLE 
	WareHouse_Details
DROP COLUMN 
	Tax_District,
DROP COLUMN 
	Average;