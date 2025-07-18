create database KMS_Study_db

SELECT * FROM [dbo].[KMS Sql Case Study]
SELECT * FROM Order_Status
---- First step is Data Optimization by formatting some selected columns into two decimal places
ALTER TABLE [dbo].[KMS Sql Case Study]
ALTER COLUMN Sales DECIMAL (15,2)

ALTER TABLE [dbo].[KMS Sql Case Study]
ALTER COLUMN Discount DECIMAL (15,2)

ALTER TABLE [dbo].[KMS Sql Case Study]
ALTER COLUMN Profit DECIMAL (15,2)

ALTER TABLE [dbo].[KMS Sql Case Study]
ALTER COLUMN Unit_Price DECIMAL (15,2)

ALTER TABLE [dbo].[KMS Sql Case Study]
ALTER COLUMN Shipping_Cost DECIMAL (15,2)

ALTER TABLE [dbo].[KMS Sql Case Study]
ALTER COLUMN Product_Base_Margin DECIMAL (15,2)

---- 1. Which product category had the highest sales? ----

SELECT TOP 1 Product_Category, SUM(Sales) AS [Sales]
FROM [dbo].[KMS Sql Case Study]
GROUP BY Product_Category
ORDER BY [Sales] DESC



---- 2. What are the Top 3 and Bottom 3 regions in terms of sales? ----
--TOP 3
SELECT TOP 3 Region, SUM(Sales) AS [Sales]
FROM [dbo].[KMS Sql Case Study] 
GROUP BY Region
ORDER BY [Sales] DESC

--BOTTOM 3
SELECT TOP 3 Region, SUM(Sales) AS [Sales]
FROM [dbo].[KMS Sql Case Study] 
GROUP BY Region
ORDER BY [Sales] ASC

---- 3. What were the total sales of appliances in Ontario? ----

SELECT SUM(Sales) AS [Total Sales]
FROM [dbo].[KMS Sql Case Study]
WHERE Region = 'Ontario' AND Product_Sub_Category = 'Appliances'

---- 4. Advise the management of KMS on what to do to increase the revenue from the bottom 10 customers ----
-- First: Identifying the bottom 10 customers
SELECT TOP 10 Customer_Name, SUM(Sales) AS Sales
FROM [dbo].[KMS Sql Case Study]
GROUP BY Customer_Name
ORDER BY Sales ASC

-- Second: Advise to management
--Sending personalized emails or SMS with incentives (e.g., 10% off next purchase).
--Recommending complementary or higher-value products at checkout for repeat customers that buy low-value products.
--Enroll them in a loyalty program with tiered rewards to encourage repeat purchases and build long-term engagement.
--Offer targeted discounts or bundles based on their past purchases to build conversion and interest.

---- 5. KMS incurred the most shipping cost using which shipping method? ----

SELECT TOP 1 Ship_Mode, SUM(Shipping_Cost) AS [Total Shipping Cost]
FROM [dbo].[KMS Sql Case Study]
GROUP BY Ship_Mode
ORDER BY [Total Shipping Cost] DESC

---- 6. Who are the most valuable customers, and what products or services do they typically purchase? ----
--First: Identifying the most valuable customers in terms of total sales
SELECT TOP 5 Customer_Name, SUM(Sales) AS Total_Sales 
FROM [dbo].[KMS Sql Case Study]
GROUP BY Customer_Name
ORDER BY Total_Sales DESC

--Second: Identifying the products they purchase

WITH Customer_Sales AS (
    SELECT 
        Customer_Name,
        SUM(Sales) AS Total_Sales
    FROM [dbo].[KMS Sql Case Study]
    GROUP BY Customer_Name
),

Top_Customers AS (
    SELECT TOP 5 Customer_Name, Total_Sales
    FROM Customer_Sales
    ORDER BY Total_Sales DESC
),

Customer_Category_Sales AS (
    SELECT 
        o.[Customer_Name], 
        o.[Product_Category],
        SUM(o.[Sales]) AS Category_Sales
    FROM [dbo].[KMS Sql Case Study] AS o
    JOIN Top_Customers AS tc
        ON o.[Customer_Name] = tc.Customer_Name
    GROUP BY o.[Customer_Name], o.[Product_Category]
)

SELECT 
    ccs.Customer_Name,
    ccs.Product_Category,
    ccs.Category_Sales
FROM Customer_Category_Sales AS ccs
ORDER BY ccs.Category_Sales DESC;


---- 7. Which small business customer had the highest sales? ----

SELECT TOP 1 Customer_Name, SUM(sales) AS [Highest Sales]
FROM [dbo].[KMS Sql Case Study]
WHERE Customer_Segment = 'Small Business'
GROUP BY Customer_Name
ORDER BY [Highest Sales] DESC

---- 8. Which Corporate Customer placed the most number of orders in 2009 – 2012? ----

SELECT TOP 1 Customer_Name, SUM(Order_Quantity) AS [Number Of Orders]
FROM [dbo].[KMS Sql Case Study]
WHERE Customer_Segment = 'Corporate' AND YEAR(Order_Date) BETWEEN '2009' AND '2012'
GROUP BY Customer_Name
ORDER BY [Number Of Orders] DESC

---- 9. Which consumer customer was the most profitable one? ----

SELECT TOP 1 Customer_Name, SUM(Profit) as Profit
FROM [dbo].[KMS Sql Case Study]
WHERE Customer_Segment = 'Consumer'
GROUP BY Customer_Name
ORDER BY Profit DESC

---- 10. Which customer returned items, and what segment do they belong to? ----

--First add the flat file Order_Status

SELECT k.Customer_Name, k.Customer_Segment 
FROM [dbo].[KMS Sql Case Study] k
JOIN Order_Status o
ON k.Order_ID = o.Order_ID
WHERE o.[Status] = 'Returned'

---- 11. If the delivery truck is the most economical but the slowest shipping method and Express Air is the fastest but the most expensive one, do you think the company appropriately spent shipping costs based on the Order Priority? Explain your answer ----

SELECT Order_Priority, 
       Ship_Mode, 
	   COUNT(Order_ID) AS Number_Of_Orders, 
	   SUM(Shipping_Cost) AS Total_Shipping_Cost, 
	   AVG(Shipping_Cost) AS Avg_Shipping_Cost
FROM [dbo].[KMS Sql Case Study] 
GROUP BY Order_Priority, Ship_Mode
ORDER BY Order_Priority, Avg_Shipping_Cost DESC

--The company did not appropriately spend shipping costs based on order priority. The data shows that some lower-priority orders incurred higher shipping costs than higher-priority ones