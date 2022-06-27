
--Display a list of all property names and their property id’s for Owner Id: 1426. 

SELECT p.Id as'Property ID', p.[Name] as 'Property Name'
FROM  [dbo].[Property] as p 
LEFT JOIN [dbo].[OwnerProperty] as OP ON OP.PropertyId = p. Id 
LEFT JOIN [dbo].[Owners] as O ON O.Id = OP.OwnerId
WHERE OP.[OwnerId] = 1426 