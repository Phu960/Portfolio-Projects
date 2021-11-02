SELECT *
FROM project_b..house

--Convert DateTime format to Date 
ALTER TABLE project_b..house
ADD sale_date DATE

UPDATE project_b..house
SET sale_date = CONVERT(DATE, SaleDate)


--Populate missing PropertyAddress data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM project_b..house a
JOIN project_b..house b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM project_b..house a
JOIN project_b..house b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into Individual Columns (Address, City, State) using PARSENAME
SELECT 
PARSENAME(REPLACE(PropertyAddress, ',' , '.'), 2),
PARSENAME(REPLACE(PropertyAddress, ',' , '.'), 1)
FROM project_b..house

ALTER TABLE project_b..house
ADD Property_Address VARCHAR(100)

ALTER TABLE project_b..house
ADD Property_City VARCHAR(100)

UPDATE project_b..house
SET Property_Address = PARSENAME(REPLACE(PropertyAddress, ',' , '.'), 2)

UPDATE project_b..house
SET Property_City = PARSENAME(REPLACE(PropertyAddress, ',' , '.'), 1)

--CASE STATEMENT to replace Y to YES and N to NO
SELECT soldasvacant, COUNT(SoldAsVacant)
FROM project_b..house
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
FROM project_b..house

UPDATE project_b..house
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END

--Removing duplicates


--Using row number to count how many duplicates there are
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference 
ORDER BY UniqueID
) row_num
FROM project_b..house
ORDER BY PropertyAddress

--CTE to locate all duplicate rows
WITH rownumcte AS (
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference 
ORDER BY UniqueID
) row_num
FROM project_b..house
)
SELECT *
FROM rownumcte 
WHERE row_num > 1
ORDER BY ParcelID

--Delete duplicates
WITH rownumcte AS (
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference 
ORDER BY UniqueID
) row_num
FROM project_b..house
)
DELETE
FROM rownumcte 
WHERE row_num > 1
