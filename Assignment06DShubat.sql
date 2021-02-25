--*************************************************************************--
-- Title: Assignment06
-- Author: Danielle Shubat
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-17, DanielleShubat, Created File
-- 2021-02-18, DanielleShubat, created select statements for all views to test understanding, added view permissions
--	to [vCategories], [vProducts], [vInventories], [vEmployees]
-- 2021-02-22, DanielleShubat, created views for 1-10 using provided view names
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DanielleShubat')
	 Begin 
	  Alter Database [Assignment06DB_DanielleShubat] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DanielleShubat;
	 End
	Create Database Assignment06DB_DanielleShubat;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DanielleShubat;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent (I will not be changing the view names)
[vCategories]
[vProducts]
[vInventories]
[vEmployees]
[vProductsByCategories]
[vInventoriesByProductsByDates]
[vInventoriesByEmployeesByDates]
[vInventoriesByProductsByCategories]
[vInventoriesByProductsByEmployees]
[vInventoriesForChaiAndChangByEmployees]
[vEmployeesByManager]
[vInventoriesByProductsByCategoriesByEmployees]
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
 SELECT CategoryID
	,CategoryName
 FROM dbo.Categories
GO
SELECT * FROM vCategories
GO

CREATE VIEW vProducts
With SCHEMABINDING
AS
 SELECT ProductID
	,ProductName
	,CategoryID
	,UnitPrice
 FROM dbo.Products
GO
SELECT * FROM vProducts
GO

CREATE VIEW vEmployees
With SCHEMABINDING
AS
 SELECT EmployeeID
	,EmployeeFirstName
	,EmployeeLastName
	,ManagerID
 FROM dbo.Employees
GO
SELECT * FROM vEmployees
GO

CREATE VIEW vInventories
With SCHEMABINDING
AS
 SELECT InventoryID
	,InventoryDate
	,EmployeeID
	,ProductID
	,[Count]
 FROM dbo.Inventories
GO
SELECT * FROM vInventories
GO

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON dbo.Categories TO PUBLIC;
GO
GRANT SELECT ON vCategories TO PUBLIC;
GO

DENY SELECT ON dbo.Products TO PUBLIC;
GO
GRANT SELECT ON vProducts TO PUBLIC;
GO

DENY SELECT ON dbo.Employees TO PUBLIC;
GO
GRANT SELECT ON vEmployees TO PUBLIC;
GO

DENY SELECT ON dbo.Inventories TO PUBLIC;
GO
GRANT SELECT ON vInventories TO PUBLIC;
GO

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00
-- [vProductsByCategories]

/*Select
 CategoryName, ProductName, UnitPrice
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
Order by CategoryName
	,ProductName;
	GO*/

--Drop view vProductsByCategories

Create view vProductsByCategories
With Schemabinding
As
Select Top 100000 --saw from above select statement that there are currently 77 rows; used large number to allow for database expansion but concerned about eventual server load
 CategoryName, ProductName, UnitPrice
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
Order by CategoryName
	,ProductName
Go
Select * from vProductsByCategories
Go


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83
--[vInventoriesByProductsByDates]


/*Select ProductName
	,InventoryDate
	,[Count]
 From dbo.Inventories as i
 Inner Join dbo.Products as p
   On p.ProductID = i.ProductID
Order by ProductName
	,InventoryDate
	,[Count]
Go*/

-- Drop view vInventoriesByProductsByDates

Create view vInventoriesByProductsByDates
With Schemabinding
As
Select Top 100000 --231 current rows observed in view
	ProductName
	,InventoryDate
	,[Count]
 From dbo.Inventories as i
 Inner Join dbo.Products as p
   On p.ProductID = i.ProductID
Order by ProductName
	,InventoryDate
	,[Count]
Go
Select * from vInventoriesByProductsByDates
Go

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth
--[vInventoriesByEmployeesByDates]


/*Select Distinct 
  InventoryDate
  ,EmployeeFirstName +' ' + EmployeeLastname as EmployeeFullName 
 From dbo.Inventories as i
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
Order by inventorydate
Go*/

-- Drop view vInventoriesByEmployeesByDates

Create View vInventoriesByEmployeesByDates
With Schemabinding 
As
Select Distinct top 1000000 --3 current rows observed in view
  InventoryDate
  ,EmployeeFirstName +' ' + EmployeeLastName as [EmployeeFullName]
 From dbo.Inventories as i
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
Order by inventorydate
Go
Select * from vInventoriesByEmployeesByDates
Go

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54
-- [vInventoriesByProductsByCategories]

/*Select --231 current rows
 CategoryName
 ,ProductName
 ,InventoryDate
 ,[count]
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
Go*/

Create View vInventoriesByProductsByCategories
With Schemabinding
As 
Select Top 100000 --231 current rows observed in view
 CategoryName
 ,ProductName
 ,InventoryDate
 ,[count]
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
Order by 1,2,3,4; --didn't want to write out column names!
GO
Select * from vInventoriesByProductsByCategories
Go

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan
-- [vInventoriesByProductsByEmployees]

/*Select CategoryName --231 rows
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeFirstName +' ' + EmployeeLastname as [EmployeeFullName]
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
   --order by 3,1,2,5,4
Go*/

Create view vInventoriesByProductsByEmployees
With Schemabinding 
As
Select top 100000
	CategoryName --231 current rows observed in view
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeFirstName +' ' + EmployeeLastname as [EmployeeFullName]
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
 Order by 3,1,2,5,4;
Go
Select * from vInventoriesByProductsByEmployees
Go

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King
-- [vInventoriesForChaiAndChangByEmployees]

/*Select c.CategoryName -- 6 rows
	,p.ProductName
	,i.InventoryDate
	,i.[Count]
	,e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeFullName
From Employees as e 
Join Inventories AS i
	On e.EmployeeID = i.EmployeeID
Join Products as p
	On i.ProductID = p.ProductID
Join Categories as c
	On p.CategoryID = c.CategoryID
	Where i.ProductID in 
		(Select ProductID From Products Where ProductName In ('Chai', 'Chang'))
GO*/

Create View vInventoriesForChaiAndChangByEmployees
With Schemabinding
As
Select Top 100000 CategoryName -- 6 current rows observed in view
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeFirstName + ' ' + e.EmployeeLastName as [EmployeeFullName]
From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
    Where p.ProductID in 
     (Select ProductID 
      From dbo.Products 
      Where ProductName = 'chai' or ProductName = 'chang')
Order by 3, 1, 2, 5, 4;
Go
Select * from vInventoriesForChaiAndChangByEmployees
Go

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan
-- [vEmployeesByManager]

/*Select --9 rows
	m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
	,e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
From Employees as e
	INNER JOIN Employees AS m
	On e.ManagerID = m.EmployeeID;
GO*/

Create View vEmployeesByManager
With Schemabinding 
As
Select top 100000 --9 current rows observed in view
	[Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
	,[Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
From dbo.vEmployees as e --created Employees view; could also use dbo.Employees?
	INNER JOIN dbo.vEmployees AS m
	On e.ManagerID = m.EmployeeID
Order By 1,2;
Go
Select * from vEmployeesByManager;
Go

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

 Create View vInventoriesByProductsByCategoriesByEmployees
 With Schemabinding
 As
 Select 
	p.CategoryID
	,CategoryName 
	,p.ProductID
	,ProductName
	,UnitPrice
	,e.EmployeeID
	,EmployeeFirstName
	,EmployeeLastName
	,ManagerID
	,InventoryID
	,InventoryDate
	Count 
 From dbo.vCategories as c
 Inner Join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
 Inner Join dbo.vInventories as i
	On p.ProductID = i.ProductID
 Inner Join dbo.vEmployees as e
	On i.EmployeeID = e.EmployeeID;
Go
Select * from vInventoriesByProductsByCategoriesByEmployees;
Go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/