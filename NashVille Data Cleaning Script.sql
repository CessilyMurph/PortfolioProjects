

--Cleaning Data in SQL Queries

Select * 
From PortfolioCess.dbo.nashvillehousing

-- Standardize Date Format

Select SaleDate, Convert(Date, SaleDate)
From PortfolioCess.dbo.nashvillehousing

Update nashvillehousing
SET SaleDate = Convert(Date, SaleDate) 

--columns not updating; alt update method 

ALTER TABLE nashvillehousing
Add SaleDateConverted Date; 

Update nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioCess.dbo.nashvillehousing 

-- Populate Property Address

Select *
From PortfolioCess.dbo.nashvillehousing 
Where PropertyAddress is null
order by ParcelID

Select *
From PortfolioCess.dbo.nashvillehousing a
JOIN PortfolioCess.dbo.nashvillehousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioCess.dbo.nashvillehousing a
JOIN PortfolioCess.dbo.nashvillehousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioCess.dbo.nashvillehousing a
JOIN PortfolioCess.dbo.nashvillehousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Indiviudal Columns using Substrings

Select PropertyAddress
From PortfolioCess.dbo.nashvillehousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address -- Adding -1 gets rid of comma in query 
From PortfolioCess.dbo.nashvillehousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as City
From PortfolioCess.dbo.nashvillehousing

ALTER TABLE nashvillehousing
Add PropertySplitAddress NVARCHAR(255);

Update nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE nashvillehousing
Add PropertySplitCity NVARCHAR(255);

Update nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


Select *
From PortfolioCess.dbo.nashvillehousing  -- At the end of table two new columns were added showing cleaned up Address and City :D 


Select OwnerAddress
From PortfolioCess.dbo.nashvillehousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
From PortfolioCess.dbo.nashvillehousing



ALTER TABLE nashvillehousing
Add OwnerSplitAddress NVARCHAR(255);

Update nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
Add OwnerSplitCity NVARCHAR(255);

Update nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
ALTER TABLE nashvillehousing
Add OwnerSplitState NVARCHAR(255);

Update nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioCess.dbo.nashvillehousing

--Change Y and N to Yes and No Using Case Statements 

Select Distinct(SoldAsVacant)  --We see that data is grouped in N, Yes, Y, No 
From PortfolioCess.dbo.nashvillehousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From PortfolioCess.dbo.nashvillehousing
Group by SoldAsVacant
Order by 2 

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes' 
WHEN SoldAsVacant = 'N' then 'No' 
ELSE SoldAsVacant
END
From PortfolioCess.dbo.nashvillehousing



Update nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes' 
WHEN SoldAsVacant = 'N' then 'No' 
ELSE SoldAsVacant
END
From PortfolioCess.dbo.nashvillehousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From PortfolioCess.dbo.nashvillehousing
Group by SoldAsVacant
Order by 2 

-- Remove Duplicates 
WITH RowNumCTE AS( 
Select *, ROW_NUMBER() OVER (
Partition BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order BY
UniqueID) row_num
From PortfolioCess.dbo.nashvillehousing 
--order by ParcelID



)
DELETE
From RowNumCTE 
where row_num > 1
--order by PropertyAddress


--Checking if any duplicates remain 
WITH RowNumCTE AS( 
Select *, ROW_NUMBER() OVER (
Partition BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order BY
UniqueID) row_num
From PortfolioCess.dbo.nashvillehousing 
--order by ParcelID



)
Select *
From RowNumCTE 
where row_num > 1
--order by PropertyAddress


--Delete Unused Columns; YIKES

Select *
From PortfolioCess.dbo.nashvillehousing 

ALTER TABLE PortfolioCess.dbo.nashvillehousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioCess.dbo.nashvillehousing 
DROP COLUMN SaleDate

