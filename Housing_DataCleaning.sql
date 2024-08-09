/* 
Data Cleaning
*/

-- Select all from the table
Select *
From nashvillehousing

-- Standarize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From nashvillehousing

Update nashvillehousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Populate Property Address data
Select PropertyAddress
From nashvillehousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From nashvillehousing a
Join nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From nashvillehousing a
JOIN nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From nashvillehousing

Select
	SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from nashvillehousing

Alter Table nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From nashvillehousing

-- Using Parsename to separate the address
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From nashvillehousing


Alter Table nashvillehousing
Add OwnerSplitAddress Nvarchar(255)

Alter Table nashvillehousing
Add OwnerSplitCity Nvarchar(255)

Alter Table nashvillehousing
Add OwnerSplitState Nvarchar(255)

Update nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Update nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

Update nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerADDRESS, ',','.'),1)

SELECT *
FROM nashvillehousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From nashvillehousing

Update nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From nashvillehousing
)
DELETE 
FROM RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- Delete Unused Columns
Alter Table nashvillehousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table nashvillehousing
Drop Column SaleDate

Select *
From nashvillehousing



