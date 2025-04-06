

/* In the Project Experiment Focus About Data Cleaning in SQL */


USE sql_project;

SELECT * FROM nashvillehousingdata
ORDER BY UniqueID ASC;

-- Standardize Date Format

UPDATE nashvillehousingdata
SET saledate = STR_TO_DATE(saledate, '%M %d, %Y');

-- Populate Property Address data

SELECT *
FROM nashvillehousingdata
WHERE propertyaddress IS NOT NULL
ORDER BY ParcelID ASC;

SELECT 
a.Parcelid, a.PropertyAddress, b.Parcelid, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousingdata a INNER JOIN nashvillehousingdata b
ON a.Parcelid= b.parcelid AND a.Uniqueid <> b.Uniqueid
WHERE a.PropertyAddress IS NOT NULL;

UPDATE nashvillehousingdata a 
JOIN  nashvillehousingdata b
ON a.Parcelid = b.Parcelid AND a.Uniqueid <> b.Uniqueid
SET a.nashvillehousingdata = b.nashvillehousingdata
WHERE a.PeopertyAddress IS NULL;



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Street,
TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1)) as City
FROM nashvillehousingdata;

ALTER TABLE nashvillehousingdata
ADD COLUMN PropertySplitAddress VARCHAR(100);

UPDATE nashvillehousingdata
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

ALTER TABLE nashvillehousingdata
ADD COLUMN PropertySplitCity VARCHAR(100);

UPDATE nashvillehousingdata
SET PropertySplitCity= SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1);

SELECT * FROM nashvillehousingdata;


-- Breaking out  OwnerAddress into Individual Columns (Address, City, State)

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1) as Address,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',', -1)) AS City,
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) as State
FROM  nashvillehousingdata;

ALTER TABLE nashvillehousingdata
ADD COLUMN OwnerSplitAddress VARCHAR(100);

UPDATE nashvillehousingdata 
SET OwnerSplitAddress= SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousingdata
ADD COLUMN OwnerSplitCity VARCHAR(100);

UPDATE nashvillehousingdata
SET OwnerSplitCity= SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);


ALTER TABLE nashvillehousingdata
ADD COLUMN OwnerSplitStat VARCHAR(100);

UPDATE nashvillehousingdata
SET OwnerSplitStat= SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT  * FROM nashvillehousingdata;


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM nashvillehousingdata
GROUP BY SoldAsVacant
ORDER BY 1;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 WHEN SoldAsVacant= 'N' THEN 'No'
     ELSE SoldAsVacant
END
FROM nashvillehousingdata;


UPDATE nashvillehousingdata
SET SoldAsVacant= CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
						WHEN SoldAsVacant= 'N' THEN 'No'
                        ELSE SoldAsVacant
                   END; 



-- Remove Duplicates 
WITH RowNumberCTE  AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
					ORDER BY UniqueID) as RowNumber
FROM nashvillehousingdata )

SELECT * FROM RowNumberCTE 
WHERE RowNumber > 1
ORDER BY propertyAddress;



-- Delete Unused Columns

ALTER TABLE  nashvillehousingdata
DROP COLUMN TaxDistrict,
DROP COLUMN  Bedrooms, 
DROP COLUMN   FullBath, 
DROP COLUMN    HalfBath;


SELECT * FROM nashvillehousingdata;







				
