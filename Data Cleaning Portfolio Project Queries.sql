/*

	Cleaning data in SQL queries
	
*/

select * from nashvillehousing;

--Standardize date format

alter table nashvillehousing
alter column saledate type date;


--Populate Property address data

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
 on a.parcelid = b.parcelid
 and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update nashvillehousing
set propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
 on a.parcelid = b.parcelid
 and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

--Breaking out Address into Individual columns(Address, city, state)

select split_part(propertyaddress,',',1),
split_part(propertyaddress,',',2)
from nashvillehousing

--Added two new columns 'property_address' &  'property_city'

--Add data into new columns
update nashvillehousing
set property_address = split_part(propertyaddress,',',1)

update nashvillehousing
set property_city = split_part(propertyaddress,',',2)

--Create new columns owner_address, owner_city & owner_state
update nashvillehousing
set owner_address = split_part(owneraddress,',',1);

update nashvillehousing
set owner_city = split_part(owneraddress,',',2);

update nashvillehousing
set owner_state = split_part(owneraddress,',',3);

select owneraddress, owner_address, owner_city, owner_state from nashvillehousing;


--Change Y and N to Yes and No in 'soldasvacant' field

select distinct soldasvacant from nashvillehousing;

Update nashvillehousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
    					when soldasvacant = 'N' then 'No'
						else soldasvacant
				   end
				  

--Remove Duplicates


with rowdup as(
select *,
row_number() over(
partition by parcelid,
		     propertyaddress,
			 saledate,
		     saleprice,
			 legalreference
	order by uniqueid )row_num
from nashvillehousing
order by parcelid
	)
Delete from nashvillehousing 
where uniqueid in (select uniqueid from rowdup where row_num>1)
	

--Delete unused columns

Alter table nashvillehousing
Drop column propertyaddress,
Drop column owneraddress,
Drop column taxdistrict

