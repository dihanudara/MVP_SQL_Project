
--a--Display a list of all property names and their property id’s for Owner Id: 1426. 

SELECT op.OwnerId, p.Id as'Property ID', p.[Name] as 'Property Name'
FROM  [dbo].[Property] as p 
LEFT JOIN [dbo].[OwnerProperty] as op ON op.PropertyId = p. [Id]
LEFT JOIN [dbo].[Owners] as o ON o.Id = op.[OwnerId]
WHERE op.[OwnerId] = 1426; 

--SELECT p.Id as'Property ID', p.[Name] as 'Property Name'
--FROM  [dbo].[Property] as p 
--INNER JOIN [dbo].[OwnerProperty] as op ON op.PropertyId = p. Id 
--INNER JOIN [dbo].[Owners] as o ON o.Id = op.OwnerId
--WHERE op.[OwnerId] = 1426;


--b--Display the current home value for each property in question a). 

SELECT op.OwnerId, p.Id as'Property ID', p.[Name] as 'Property Name', pv.Value as 'Current Home Value'
FROM  [dbo].[PropertyHomeValue] AS pv
LEFT JOIN [dbo].[Property] as p ON pv.[PropertyId] = P.[Id]
LEFT JOIN [dbo].[OwnerProperty] as op ON OP.[PropertyId] = p. Id 
--LEFT JOIN [dbo].[Owners] as o ON o.Id = op.[OwnerId]
WHERE op.[OwnerId] = 1426 AND PV.IsActive = '1'; 



--SELECT
--  OwnerProperty.OwnerId
--  ,Property.Id
--  ,Property.Name
--  ,PropertyHomeValue.[Value]
--FROM
--  Property
--  LEFT OUTER JOIN OwnerProperty
--    ON Property.Id = OwnerProperty.PropertyId
--  LEFT OUTER JOIN PropertyHomeValue
--    ON Property.Id = PropertyHomeValue.PropertyId
--WHERE
--  OwnerProperty.OwnerId = 1426
--  AND PropertyHomeValue.IsActive = N'True'


--c--For each property in question a), return the following:                                                                      
--i--Using rental payment amount, rental payment frequency, tenant start date and tenant end date to 
--   write a query that returns the sum of all payments from start date to end date. 

--SELECT tpf.Name, DATEDIFF(WEEK, tp.[StartDate],tp.[EndDate])
--FROM OwnerProperty op
--LEFT JOIN Property p ON op.PropertyId = p.Id
--LEFT JOIN TenantProperty tp ON tp.PropertyId = op.PropertyId
--LEFT JOIN TenantPaymentFrequencies  tpf ON tp.PaymentFrequencyId = tpf.Id
--WHERE op.OwnerId = 1426 AND pf.Name='Weekly'; =52 weeks

--SELECT tpf.Name, DATEDIFF(WEEK, tp.[StartDate],tp.[EndDate])
--FROM OwnerProperty op
--LEFT JOIN Property p ON op.PropertyId = p.Id
--LEFT JOIN TenantProperty tp ON tp.PropertyId = op.PropertyId
--LEFT JOIN TenantPaymentFrequencies  tpf ON tp.PaymentFrequencyId = tpf.Id
--WHERE op.OwnerId = 1426 AND pf.Name='Fortnightly'; =52 weeks

--SELECT tpf.Name, DATEDIFF(WEEK, tp.[StartDate],tp.[EndDate])
--FROM OwnerProperty op
--LEFT JOIN Property p ON op.PropertyId = p.Id
--LEFT JOIN TenantProperty tp ON tp.PropertyId = op.PropertyId
--LEFT JOIN TenantPaymentFrequencies  tpf ON tp.PaymentFrequencyId = tpf.Id
--WHERE op.OwnerId = 1426 AND pf.Name='Monthly'; = 52 weeks

SELECT op.OwnerId, p.Id AS 'Property Id', p.Name AS 'Property Name', tp.StartDate AS 'TenantStartDate', tp.EndDate AS 'TenantEndDate', 
tpf.Name AS 'Payment Frequencies', tp.PaymentAmount AS 'Payment Amount ', 
CAST(CASE 
	WHEN tpf.Name = 'Weekly' THEN DATEDIFF(WEEK, tp.StartDate, tp.EndDate)*tp.PaymentAmount  
	WHEN tpf.Name = 'Fortnightly' THEN DATEDIFF(WEEK, tp.StartDate, tp.EndDate)*tp.PaymentAmount/2
	WHEN tpf.Name = 'Monthly' THEN DATEDIFF(Week, tp.StartDate, tp.EndDate)*tp.PaymentAmount/4
END AS decimal(18,2)) AS 'Total Payment Amount'

FROM Property AS p 
LEFT JOIN [dbo].[OwnerProperty] AS op ON p.Id=op.PropertyId 
LEFT JOIN [dbo].[PropertyRentalPayment] AS prp ON p.Id=prp.PropertyId
LEFT JOIN [dbo].[TargetRentType] AS tpf ON prp.FrequencyType=tpf.Id
LEFT JOIN [dbo].[TenantProperty]AS tp ON p.Id=tp.PropertyId 
LEFT JOIN [dbo].[Tenant] as t ON tp.[TenantId] = t.[Id]
LEFT JOIN [dbo].[Person] as per ON t.[Id] = per.[Id]
LEFT JOIN [dbo].[PropertyHomeValue] AS phv ON p.Id=phv.PropertyId
LEFT JOIN [dbo].[PropertyExpense] AS pe ON p.Id=pe.PropertyId 
WHERE op.OwnerId=1426 AND phv.IsActive=1;



--c. ii. Display the yield

--Yield = (TotalRent-Expenses)/CuurentHomeValue*100

SELECT p.[Name] AS PropertyName , p.Id AS PropertyID , phv.[Value] AS HomeValue ,

trt.[Name] AS RentalPaymentFrequency ,
prp.Amount AS RentalPaymentAmount , tp.StartDate AS TenantStartDate , tp.EndDate AS TenantEndDate,
( (
(CASE 
WHEN trt.[Name] ='Weekly' THEN (DATEDIFF(wk,tp.StartDate, tp.EndDate)*prp.Amount)
WHEN trt.[Name] ='Fortnightly' THEN ((DATEDIFF(wk,tp.StartDate, tp.EndDate)/2)*prp.Amount)
ELSE (DATEDIFF(m,tp.StartDate, tp.EndDate)*prp.Amount) 

END )-ISNULL(SUM(pe.Amount),0) )/phv.[Value] )*100 AS Yield  

FROM Property AS p 
LEFT JOIN OwnerProperty AS op ON p.Id=op.PropertyId 
LEFT JOIN PropertyRentalPayment AS prp ON p.Id=prp.PropertyId
LEFT JOIN TargetRentType AS trt ON prp.FrequencyType=trt.Id
LEFT JOIN TenantProperty AS tp ON p.Id=tp.PropertyId 
LEFT JOIN PropertyHomeValue AS phv ON p.Id=phv.PropertyId 
LEFT JOIN PropertyExpense AS pe ON p.Id=pe.PropertyId
WHERE op.OwnerId=1426 AND phv.IsActive=1 
GROUP BY p.[Name],p.Id,phv.[Value],trt.[Name],prp.Amount,tp.StartDate,tp.EndDate;


--d--Display all the jobs available

SELECT  DISTINCT j.Id AS JobId, j.PropertyId, j.OwnerId, j.JobDescription,js.Status as JobStatus, j.JobStartDate, j.JobEndDate, jm.IsActive
FROM [dbo].[Job] as j
LEFT JOIN JobMedia as jm ON j.Id = jm.JobId
LEFT JOIN [dbo].[JobStatus] as js ON js.Id = J.JobStatusId
WHERE jm.IsActive = '1' AND JS.Id IN(1,2,3)
ORDER BY js.Status;


--e--Display all property names, current tenants first and last names and rental payments per week/ fortnight/month 
--for the properties in question a). 

--SELECT pr.Name as 'Property Name', pe.FirstName as 'Tenant First Name', pe.LastName as 'Tenanat Last Name',tpf.Name as 'Payment Frequency',
--CAST(CASE 
--	WHEN tpf.Name = 'Weekly' THEN tp.PaymentAmount
--	WHEN tpf.Name = 'Fortnightly' THEN tp.PaymentAmount/2
--	WHEN tpf.Name = 'Monthly' THEN tp.PaymentAmount/4
--END AS NUMERIC(18,2)) AS 'Rental Payment Per Week',

--CAST(CASE 
--	WHEN tpf.Name = 'Weekly' THEN tp.PaymentAmount*2
--	WHEN tpf.Name = 'Fortnightly' THEN tp.PaymentAmount
--	WHEN tpf.Name = 'Monthly' THEN tp.PaymentAmount/2
--END AS NUMERIC(18,2)) AS 'Rental Payment Per Fortnight',

--CAST(CASE 
--	WHEN tpf.Name = 'Weekly' THEN tp.PaymentAmount*4
--	WHEN tpf.Name = 'Fortnightly' THEN tp.PaymentAmount*2
--	WHEN tpf.Name = 'Monthly' THEN tp.PaymentAmount
--END AS NUMERIC(18,2)) AS 'Rental Payment Per Month'

--FROM [dbo].[Property] as pr
--LEFT JOIN [dbo].[OwnerProperty] as op ON pr.[Id] = op.[PropertyId]
--LEFT JOIN [dbo].[TenantProperty] as tp ON tp.[PropertyId] = pr.[Id]
--LEFT JOIN [dbo].[Tenant] as t ON tp.[TenantId] = t.[Id]
--LEFT JOIN [dbo].[Person] as pe ON t.[Id] = pe.[Id]
--LEFT JOIN [dbo].[TenantPaymentFrequencies] as tpf ON tpf.[Id] = tp.[PaymentFrequencyId]
--WHERE op.[OwnerId] = 1426;

SELECT p.Name as 'Property Name', per.FirstName as 'Tenant First Name', per.LastName as 'Tenanat Last Name',trt.Name as 'Payment Frequency',
CAST(CASE 
	WHEN trt.Name = 'Weekly' THEN tp.PaymentAmount
	WHEN trt.Name = 'Fortnightly' THEN tp.PaymentAmount/2
	WHEN trt.Name = 'Monthly' THEN tp.PaymentAmount/4
END AS NUMERIC(18,2)) AS 'Rental Payment Per Week',

CAST(CASE 
	WHEN trt.Name = 'Weekly' THEN tp.PaymentAmount*2
	WHEN trt.Name = 'Fortnightly' THEN tp.PaymentAmount
	WHEN trt.Name = 'Monthly' THEN tp.PaymentAmount/2
END AS NUMERIC(18,2)) AS 'Rental Payment Per Fortnight',

CAST(CASE 
	WHEN trt.Name = 'Weekly' THEN tp.PaymentAmount*4
	WHEN trt.Name = 'Fortnightly' THEN tp.PaymentAmount*2
	WHEN trt.Name = 'Monthly' THEN tp.PaymentAmount
END AS NUMERIC(18,2)) AS 'Rental Payment Per Month'

FROM Property AS p 
LEFT JOIN [dbo].[OwnerProperty] AS op ON p.Id=op.PropertyId 
LEFT JOIN [dbo].[PropertyRentalPayment] AS prp ON p.Id=prp.PropertyId
LEFT JOIN [dbo].[TargetRentType] AS trt ON prp.FrequencyType=trt.Id
LEFT JOIN [dbo].[TenantProperty]AS tp ON p.Id=tp.PropertyId 
LEFT JOIN [dbo].[Tenant] as t ON tp.[TenantId] = t.[Id]
LEFT JOIN [dbo].[Person] as per ON t.[Id] = per.[Id]
LEFT JOIN [dbo].[PropertyHomeValue] AS phv ON p.Id=phv.PropertyId
LEFT JOIN [dbo].[PropertyExpense] AS pe ON p.Id=pe.PropertyId 
WHERE op.OwnerId=1426 AND phv.IsActive=1;



