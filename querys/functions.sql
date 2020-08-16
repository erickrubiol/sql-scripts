-- Create a function that counts to 
DECLARE @cnt INT = 20;
DECLARE @n VARCHAR(50) = REPLICATE('* ',@cnt)

WHILE @cnt > 0
BEGIN
   PRINT @n ;
   SET @cnt = @cnt - 1;
   SET @n = REPLICATE('* ',@cnt);
END;
GO