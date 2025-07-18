-- Create the analysis database
CREATE DATABASE KMS_Study_db

-- Load data
SELECT * FROM [dbo].[KMS Sql Case Study]
SELECT * FROM Order_Status

-- ======================================
-- 🔧 DATA OPTIMIZATION SECTION
-- ======================================

-- Format numeric columns for consistency and precision
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

-- ======================================
-- 1️⃣ HIGHEST SELLING PRODUCT CATEGORY
-- ======================================

-- Identifies the top-performing product category by total revenue — valuable for demand planning
SELECT TOP 1 Product_Category, SUM(Sales) AS [Sales]
FROM [dbo].[KMS Sql Case Study]
GROUP BY Product_Category
ORDER BY [Sales] DESC

-- ======================================
-- 2️⃣ TOP 3 & BOTTOM 3 SALES REGIONS
-- ======================================

-- Highlights best-performing regions to double down on and underperforming ones for improvement
-- Top 3 Regions
SELECT TOP 3 Region, SUM(Sales) AS [Sales]
FROM [dbo].[KMS Sql Case Study] 
GROUP BY Region
ORDER BY [Sales] DESC

-- Bottom 3 Regions
SELECT TOP 3 Region, SUM(Sales) AS [Sales]
FROM [dbo].[KMS Sql Case Study] 
GROUP BY Region
ORDER BY [Sales] ASC

-- ======================================
-- 3️⃣ TOTAL APPLIANCE SALES IN ONTARIO
-- ======================================

-- Region-specific category revenue — supports localized marketing and stock decisions
SELECT SUM(Sales) AS [Total Sales]
FROM [dbo].[KMS Sql Case Study]
WHERE Region = 'Ontario' AND Product_Sub_Category = 'Appliances'

-- ======================================
-- 4️⃣ BOTTOM 10 CUSTOMERS + STRATEGIC ADVICE
-- ======================================

-- Step 1: Identify bottom 10 customers by total sales
SELECT TOP 10 Customer_Name, SUM(Sales) AS Sales
FROM [dbo].[KMS Sql Case Study]
GROUP BY Customer_Name
ORDER BY Sales ASC

-- Step 2: Management Recommendations (explained below)
-- 📌 Strategy:
-- • Personalized SMS/email incentives (e.g., 10% off next order)
-- • Upsell/cross-sell with relevant product recommendations
-- • Loyalty program to boost engagement
-- • Bundle low-value purchases to increase cart size

-- ======================================
-- 5️⃣ HIGHEST SHIPPING COST METHOD
-- ======================================

-- Identifies the shipping method with the most cost impact, useful for supply chain optimization
SELECT TOP 1 Ship_Mode, SUM(Shipping_Cost) AS [Total Shipping Cost]
FROM [dbo].[KMS Sql Case Study]
GROUP BY Ship_Mode
ORDER BY [Total Shipping Cost] DESC

-- ======================================
-- 6️⃣ TOP CUSTOMERS & THEIR FAVORITE CATEGORIES
-- ======================================

-- Step 1: Identify top 5 most valuable customers by revenue
SELECT TOP 5 Customer_Name, SUM(Sales) AS Total_Sales 
FROM [dbo].[KMS Sql Case Study]
GROUP BY Customer_Name
ORDER BY Total_Sales DESC

-- Step 2: Analyze their top-purchased product categories
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

-- Final Output: Which categories your top customers invest in the most
SELECT 
    ccs.Customer_Name,
    ccs.Product_Category,
    ccs.Category_Sales
FROM Customer_Category_Sales AS ccs
ORDER BY ccs.Category_Sales DESC;

-- ======================================
-- 7️⃣ TOP SMALL BUSINESS CUSTOMER
-- ======================================

-- Determines the most lucrative customer from the Small Business segment
SELECT TOP 1 Customer_Name, SUM(sales) AS [Highest Sales]
FROM [dbo].[KMS Sql Case Study]
WHERE Customer_Segment = 'Small Business'
GROUP BY Customer_Name
ORDER BY [Highest Sales] DESC

-- ======================================
-- 8️⃣ MOST ACTIVE CORPORATE CUSTOMER (2009–2012)
-- ======================================

-- Tracks which corporate customer placed the most orders during this period
SELECT TOP 1 Customer_Name, SUM(Order_Quantity) AS [Number Of Orders]
FROM [dbo].[KMS Sql Case Study]
WHERE Customer_Segment = 'Corporate' AND YEAR(Order_Date) BETWEEN '2009' AND '2012'
GROUP BY Customer_Name
ORDER BY [Number Of Orders] DESC

-- ======================================
-- 9️⃣ MOST PROFITABLE CONSUMER CUSTOMER
-- ======================================

-- Determines which consumer customer contributed the most net profit
SELECT TOP 1 Customer_Name, SUM(Profit) as Profit
FROM [dbo].[KMS Sql Case Study]
WHERE Customer_Segment = 'Consumer'
GROUP BY Customer_Name
ORDER BY Profit DESC

-- ======================================
-- 🔁 RETURNS ANALYSIS: WHO RETURNED ITEMS?
-- ======================================

-- Combines order status with customer segment to identify return behavior
SELECT k.Customer_Name, k.Customer_Segment 
FROM [dbo].[KMS Sql Case Study] k
JOIN Order_Status o
ON k.Order_ID = o.Order_ID
WHERE o.[Status] = 'Returned'

-- ======================================
-- 🔍 SHIPPING COST vs ORDER PRIORITY
-- ======================================

-- Evaluates whether KMS used cost-effective shipping aligned with order urgency
SELECT Order_Priority, 
       Ship_Mode, 
	   COUNT(Order_ID) AS Number_Of_Orders, 
	   SUM(Shipping_Cost) AS Total_Shipping_Cost, 
	   AVG(Shipping_Cost) AS Avg_Shipping_Cost
FROM [dbo].[KMS Sql Case Study] 
GROUP BY Order_Priority, Ship_Mode
ORDER BY Order_Priority, Avg_Shipping_Cost DESC

-- 📌 Insight: Shipping cost allocation is inefficient.
-- Low-priority orders sometimes used expensive shipping methods.
-- Recommend enforcing a cost-priority alignment policy to improve operational cost control.

