

-- << Cleaning Data in SQL Queries >> --


SELECT *
FROM portfolioproject.nashvillehousingdata;


-- Populate Property Address Data --


SELECT *
FROM portfolioproject.nashvillehousingdata
-- WHERE propertyaddress is null;
ORDER BY parcelId;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, IFNULL(a.propertyaddress, b.propertyaddress)
FROM portfolioproject.nashvillehousingdata a
JOIN portfolioproject.nashvillehousingdata b
	ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE portfolioproject.nashvillehousingdata a
JOIN portfolioproject.nashvillehousingdata b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
SET a.propertyaddress = IFNULL(a.propertyaddress, b.propertyaddress)
WHERE a.propertyaddress IS NULL;


-- Breaking Out Address into Individual Columns (Address, City, State) --


SELECT propertyaddress
FROM portfolioproject.nashvillehousingdata;

SELECT SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress)-1) AS address,
SUBSTRING(propertyaddress, LOCATE(',', propertyaddress)+1, LENGTH(propertyaddress)) AS address
FROM portfolioproject.nashvillehousingdata;

ALTER TABLE nashvillehousingdata
ADD propertysplitaddress VARCHAR(255);

UPDATE nashvillehousingdata
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress)-1);

ALTER TABLE nashvillehousingdata
ADD propertysplitcity VARCHAR(255);

UPDATE nashvillehousingdata
SET propertysplitcity = SUBSTRING(propertyaddress, LOCATE(',', propertyaddress)+1, LENGTH(propertyaddress));


SELECT owneraddress
FROM nashvillehousingdata;


SELECT
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 1), ',', -1),
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1),
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 3), ',', -1)
FROM nashvillehousingdata;

ALTER TABLE nashvillehousingdata
ADD ownersplitaddress VARCHAR(255);

UPDATE nashvillehousingdata
SET ownersplitaddress = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 1), ',', -1);

ALTER TABLE nashvillehousingdata
ADD ownersplitcity VARCHAR(255);

UPDATE nashvillehousingdata
SET ownersplitcity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1);

ALTER TABLE nashvillehousingdata
ADD ownersplitstate VARCHAR(255);

UPDATE nashvillehousingdata
SET ownersplitstate = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 3), ',', -1);


-- Change Y and N to Yes and No in "Sold as Vacant" field --


SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashvillehousingdata
GROUP BY soldasvacant
ORDER BY 2;

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
     ELSE soldasvacant
     END
FROM nashvillehousingdata;

UPDATE nashvillehousingdata
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
     ELSE soldasvacant
     END;


-- Delete unused columns --


ALTER TABLE nashvillehousingdata
DROP owneraddress,
DROP propertyaddress,
DROP taxdistrict;

ALTER TABLE nashvillehousingdata
DROP saledate;
